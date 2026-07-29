# Enterprise VCP to AWS Migration Simulation

Enterprise-style simulation of a Versa Controller Platform migration to AWS using Infrastructure as Code, automation, observability, validation, incident simulation, and operational runbooks.

## Overview

This project simulates a production-style VCP to AWS migration from infrastructure provisioning through post-migration operations and incident recovery.

## Objectives

- Provision AWS infrastructure using Terraform.
- Simulate controller migration to AWS.
- Automate branch onboarding.
- Validate migration success.
- Simulate production incidents.
- Document operational recovery procedures.

## Architecture

- AWS VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- EC2 Controller
- Application Load Balancer
- CloudWatch Monitoring

## Migration Workflow

1. Infrastructure Provisioning
2. Pre-Migration Validation
3. Controller Migration
4. Branch Onboarding
5. Post-Migration Validation
6. Incident Response
7. Operational Recovery

## Automation

- Pre-Migration Validation
- Migration Execution
- Branch Onboarding
- Post-Migration Validation
- Incident Simulation

## Incident Scenarios

- Controller Unreachable
- Branch Onboarding Failure
- ALB Unhealthy
- Partial Connectivity
- Rollback Required

## Operational Runbooks

- Pre-Migration Checks
- Controller Migration
- Branch Onboarding
- Post-Migration Validation
- Controller Recovery
- Rollback Procedure

## Technology Stack

- AWS
- Terraform
- Bash
- Python
- Git & GitHub
- Amazon EC2
- Application Load Balancer
- Amazon CloudWatch
- IAM
- AWS Systems Manager

## Repository Structure

```text
vcp-to-aws-migration-simulation/
├── terraform/
├── scripts/
├── runbooks/
├── logs/
├── state/
└── README.md
