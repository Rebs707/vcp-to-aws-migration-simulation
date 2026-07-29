# Enterprise VCP to AWS Migration Simulation

Enterprise-style simulation of a Versa Controller Platform (VCP) migration to AWS using Infrastructure as Code, automation, observability, validation, and operational runbooks.

---

## Overview

This project simulates a production VCP to AWS migration from planning through post-migration operations.

---

## Objectives

- Provision AWS infrastructure with Terraform.
- Simulate controller migration.
- Automate branch onboarding.
- Validate migration success.
- Simulate production incidents.
- Document operational procedures.

---

## Architecture

- AWS VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- EC2 Controller
- Application Load Balancer
- CloudWatch Monitoring

---

## Migration Workflow

1. Infrastructure Provisioning
2. Pre-Migration Validation
3. Controller Migration
4. Branch Onboarding
5. Post-Migration Validation
6. Incident Response
7. Operational Recovery

---

## Automation

- Pre-migration validation
- Migration execution
- Branch onboarding
- Post-migration validation
- Incident simulation

---

## Incident Scenarios

- Controller unreachable
- Branch onboarding failure
- ALB unhealthy
- Partial connectivity
- Rollback required

---

## Operational Runbooks

- Pre-migration checks
- Controller migration
- Branch onboarding
- Post-migration validation
- Controller recovery
- Rollback procedure

---

## Repository Structure

```text
terraform/
scripts/
runbooks/
logs/
state/
README.md
