# Pre-Migration Checks

## Purpose

Confirm the environment is ready before the migration window.

## Procedure

1. Run `./scripts/pre_migration_validation.sh`.
2. Confirm Terraform formatting and validation pass.
3. Confirm required files and architecture documents exist.
4. Verify AWS credentials before real deployment.
5. Confirm the Git working tree is clean.
6. Record warnings and resolve blocking failures.

## Success Criteria

- No failed checks.
- AWS access confirmed for deployment.
- Repository state approved for migration.
