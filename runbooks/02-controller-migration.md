# Controller Migration

## Purpose

Execute and track the simulated VCP-to-AWS controller migration.

## Procedure

1. Run `./scripts/migrate_controller.sh`.
2. Record the generated migration ID.
3. Monitor the timestamped migration log.
4. Confirm all five migration stages complete.
5. Verify the final state is `SUCCESS`.
6. Stop the workflow if any stage fails.

## Success Criteria

- Controller migration state is `SUCCESS`.
- Controller is ready for branch onboarding.
