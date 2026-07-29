# Legacy Architecture

## Overview

This directory documents the simulated enterprise Software-Defined WAN (SD-WAN) environment before migration to AWS.

The legacy environment represents an organization operating a centrally managed, on-premises Versa Controller Platform (VCP) responsible for branch management, policy distribution, authentication, and network orchestration. Multiple branch offices connect to the corporate WAN through this controller, making it the operational center of the SD-WAN deployment.

The purpose of documenting the legacy architecture is to establish a clear baseline before migration activities begin. Understanding the existing environment is essential for planning a successful migration, validating post-migration functionality, and troubleshooting issues that may occur during the transition.

---

## Legacy Environment Components

### Multi-Tenant Versa Controller Platform (VCP)

The on-premises Versa Controller Platform manages multiple branch locations from a centralized management plane. It is responsible for controller services, policy management, device configuration, monitoring, and branch onboarding.

### Branch Offices

Remote branch locations connect securely to the controller and corporate network. Each branch receives configuration, routing policies, and management instructions from the Versa Controller Platform.

### Corporate WAN

The enterprise Wide Area Network provides connectivity between branch offices, data centers, and centralized management infrastructure. The WAN serves as the communication backbone for all SD-WAN services.

### TACACS Authentication

Administrative authentication is provided through TACACS, ensuring secure administrator access to the controller while supporting centralized identity management and role-based access control.

### Existing Routing Policies

Network routing policies define traffic forwarding, path selection, and connectivity between branch locations and enterprise resources. These policies must remain consistent throughout the migration process to prevent service disruption.

---

## Migration Objective

The objective of this project is to migrate controller management services from the on-premises Versa Controller Platform (VCP) to AWS while preserving existing branch connectivity and operational stability.

The migration focuses on relocating the management plane without disrupting production traffic. Throughout the migration, branch devices should remain operational, authentication services should continue functioning, routing policies should remain intact, and post-migration validation should confirm successful onboarding and controller communication.

This legacy architecture serves as the reference point against which the AWS-based architecture, migration procedures, validation steps, and rollback scenarios are designed.
