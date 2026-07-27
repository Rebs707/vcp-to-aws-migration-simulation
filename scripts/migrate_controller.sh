#!/usr/bin/env bash
set -uo pipefail

MIGRATION_ID="${MIGRATION_ID:-migration-$(date -u +%Y%m%dT%H%M%SZ)}"
LOG_DIR="logs/migrations"
STATE_DIR="state/migrations"
LOG_FILE="${LOG_DIR}/${MIGRATION_ID}.log"
STATE_FILE="${STATE_DIR}/${MIGRATION_ID}.state"
FAIL_AT_STEP="${FAIL_AT_STEP:-}"

mkdir -p "$LOG_DIR" "$STATE_DIR"

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

log() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(timestamp)" "$level" "$message" | tee -a "$LOG_FILE"
}

update_state() {
  local status="$1"
  local current_step="$2"

  cat > "$STATE_FILE" <<STATE
migration_id=${MIGRATION_ID}
status=${status}
current_step=${current_step}
updated_at=$(timestamp)
log_file=${LOG_FILE}
STATE
}

run_step() {
  local step_number="$1"
  local step_name="$2"

  update_state "IN_PROGRESS" "$step_name"
  log "INFO" "Starting step ${step_number}: ${step_name}"

  if [[ "$FAIL_AT_STEP" == "$step_number" ]]; then
    log "ERROR" "Injected failure at step ${step_number}: ${step_name}"
    update_state "FAILED" "$step_name"
    return 1
  fi

  sleep 1
  log "PASS" "Completed step ${step_number}: ${step_name}"
}

handle_failure() {
  local exit_code=$?
  log "ERROR" "Migration ${MIGRATION_ID} failed"
  exit "$exit_code"
}

trap handle_failure ERR

log "INFO" "Starting VCP to AWS controller migration simulation"
log "INFO" "Migration ID: ${MIGRATION_ID}"
update_state "IN_PROGRESS" "initialization"

run_step 1 "Validate migration prerequisites"
run_step 2 "Prepare AWS controller configuration"
run_step 3 "Simulate controller configuration transfer"
run_step 4 "Validate AWS controller reachability"
run_step 5 "Mark controller ready for branch onboarding"

update_state "SUCCESS" "completed"
log "SUCCESS" "Migration ${MIGRATION_ID} completed successfully"

printf '\nMigration summary\n'
printf '%s\n' '-----------------'
printf 'Migration ID: %s\n' "$MIGRATION_ID"
printf 'Status: SUCCESS\n'
printf 'State file: %s\n' "$STATE_FILE"
printf 'Log file: %s\n' "$LOG_FILE"
