resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vcp-migration-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "vcp-public-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "vcp-private-${count.index + 1}"
    Tier = "Private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vcp-migration-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "vcp-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {

  tags = {
    Name = "vcp-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "vcp-migration-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "vcp-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name        = "vcp-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vcp-alb-sg"
  }
}

resource "aws_security_group" "controller" {
  name        = "vcp-controller-sg"
  description = "Security group for the simulated controller"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from the Application Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vcp-controller-sg"
  }
}


data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "controller" {
  name = "vcp-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "vcp-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "controller_ssm" {
  role       = aws_iam_role.controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "controller" {
  name = "vcp-controller-instance-profile"
  role = aws_iam_role.controller.name
}

resource "aws_instance" "controller" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.controller.id]
  iam_instance_profile        = aws_iam_instance_profile.controller.name
  associate_public_ip_address = false

  user_data = <<-USERDATA
    #!/bin/bash
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!doctype html>
    <html>
      <body>
        <h1>VCP AWS Controller Simulation</h1>
        <p>Controller status: healthy</p>
      </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  USERDATA

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "vcp-simulated-controller"
    Role = "Controller"
  }
}

resource "aws_lb" "controller" {
  name               = "vcp-controller-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name = "vcp-controller-alb"
  }
}

resource "aws_lb_target_group" "controller" {
  name        = "vcp-controller-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "vcp-controller-target-group"
  }
}

resource "aws_lb_target_group_attachment" "controller" {
  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = aws_instance.controller.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.controller.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_cloudwatch_metric_alarm" "controller_high_cpu" {
  alarm_name          = "vcp-controller-high-cpu"
  alarm_description   = "Controller CPU utilization exceeded 80 percent"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.controller.id
  }

  tags = {
    Name = "vcp-controller-high-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "controller_status_check" {
  alarm_name          = "vcp-controller-status-check-failed"
  alarm_description   = "Controller EC2 instance or system status check failed"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.controller.id
  }

  tags = {
    Name = "vcp-controller-status-check-failed"
  }
}

resource "aws_cloudwatch_metric_alarm" "controller_unhealthy_target" {
  alarm_name          = "vcp-controller-unhealthy-target"
  alarm_description   = "Application Load Balancer detected an unhealthy controller target"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "missing"

  dimensions = {
    LoadBalancer = aws_lb.controller.arn_suffix
    TargetGroup  = aws_lb_target_group.controller.arn_suffix
  }

  tags = {
    Name = "vcp-controller-unhealthy-target"
  }
}

