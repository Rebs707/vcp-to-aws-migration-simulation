# Legacy Architecture

## Overview

A simulated enterprise SD-WAN environment hosted on an on-premises Versa Controller Platform (VCP).

## Components

- Multi-tenant Versa Controller
- Branch Office
- Corporate WAN
- TACACS Authentication
- Existing Routing Policies

## Objective

Migrate management services from the on-premises Versa Controller Platform (VCP) to AWS while preserving branch connectivity.

## Legacy Architecture

```mermaid
flowchart LR

    BO["Branch Office"]
    WAN["Corporate WAN"]
    VCP["Multi-Tenant Versa Controller (VCP)"]

    TACACS["TACACS Authentication"]
    ROUTING["Routing Policies"]

    BO --> WAN
    WAN --> VCP

    TACACS --> VCP
    ROUTING --> VCP
