# Controller Unreachable

## Purpose

Handle a migration blocked by controller or site unreachability.

## Procedure

1. Confirm the controller or branch cannot be reached.
2. Request console access from the field engineer.
3. Confirm the VCP platform remains unchanged.
4. Do not classify the event as a rollback.
5. Mark the migration as requiring rescheduling.
6. Resume onboarding after console access is restored.

## Classification

- Outcome: `RESCHEDULE`
- Rollback: Not required
- Issue report: Not required
