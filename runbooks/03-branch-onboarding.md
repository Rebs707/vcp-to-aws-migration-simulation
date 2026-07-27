# Branch Onboarding

## Purpose

Register and validate a branch against the AWS controller.

## Procedure

1. Confirm the latest migration state is successful.
2. Run `./scripts/onboard_branch.sh`.
3. Verify branch registration completes.
4. Confirm controller reachability.
5. Confirm the simulated control tunnel is established.
6. Confirm routing and branch operational status.

## Success Criteria

- Branch onboarding state is `SUCCESS`.
- Branch status is operational.
