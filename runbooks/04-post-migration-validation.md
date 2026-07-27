# Post-Migration Validation

## Purpose

Confirm the controller and branch are healthy after migration.

## Procedure

1. Run `./scripts/post_migration_validation.sh`.
2. Confirm the migration state is successful.
3. Confirm the branch onboarding state is successful.
4. Confirm simulated ALB health.
5. Confirm controller reachability.
6. Confirm branch connectivity.
7. Review PASS, WARN, and FAIL totals.

## Success Criteria

- Failed checks equal zero.
- Final validation state is `SUCCESS` or an approved `WARNING`.
