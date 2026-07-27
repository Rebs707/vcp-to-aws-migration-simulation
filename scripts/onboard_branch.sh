#!/usr/bin/env bash
set -uo pipefail

BRANCH_ID="${BRANCH_ID:-branch-001}"
CONTROLLER_URL="${CONTROLLER_URL:-http://controller.internal}"
FAIL_AT_STEP="${FAIL_AT_STEP:-}"

LOG_DIR="logs/onboarding"
STATE_DIR="state/onboarding"
LOG_FILE="${LOG_DIR}/${BRANCH_ID}.log"
STATE_FILE="${STATE_DIR}/${BRANCH_ID}.state"

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
branch_id=${BRANCH_ID}
status=${status}
current_step=${current_step}
controller_url=${CONTROLLER_URL}
updated_at=$(timestamp)
log_file=${LOG_FILE}
STATE
}

latest_migration_state() {
  find state/migrations -type f -name '*.state' 2>/dev/null | sort | tail -1
}

validate_migration() {
  local migration_state

  migration_state="$(latest_migration_state)"

  if [[ -z "$migration_state" ]]; then
    log "ERROR" "No migration state file was found"
    return 1
  fi

  if ! grep -q '^status=SUCCESS$' "$migration_state"; then
    log "ERROR" "Latest controller migration was not successful"
    return 1
  fi

  log "PASS" "Successful controller migration state found"
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
  log "ERROR" "Branch onboarding failed for ${BRANCH_ID}"
  exit "$exit_code"
}

trap handle_failure ERR

: > "$LOG_FILE"

log "INFO" "Starting branch onboarding simulation"
log "INFO" "Branch ID: ${BRANCH_ID}"
log "INFO" "Controller URL: ${CONTROLLER_URL}"

update_state "IN_PROGRESS" "migration-validation"

validate_migration
run_step 1 "Register branch with AWS controller"
run_step 2 "Validate controller reachability"
run_step 3 "Establish simulated control tunnel"
run_step 4 "Validate branch routing"
run_step 5 "Confirm branch operational status"

update_state "SUCCESS" "completed"
log "SUCCESS" "Branch ${BRANCH_ID} onboarded successfully"

printf '\nBranch onboarding summary\n'
printf '%s\n' '-------------------------'
printf 'Branch ID: %s\n' "$BRANCH_ID"
printf 'Status: SUCCESS\n'
printf 'State file: %s\n' "$STATE_FILE"
printf 'Log file: %s\n' "$LOG_FILE"
