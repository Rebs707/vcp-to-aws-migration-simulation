#!/usr/bin/env bash
set -uo pipefail

BRANCH_ID="${BRANCH_ID:-branch-001}"
FAIL_CHECK="${FAIL_CHECK:-}"

LOG_DIR="logs/validation"
STATE_DIR="state/validation"
RUN_ID="validation-$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="${LOG_DIR}/${RUN_ID}.log"
STATE_FILE="${STATE_DIR}/${RUN_ID}.state"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

mkdir -p "$LOG_DIR" "$STATE_DIR"

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

log() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(timestamp)" "$level" "$message" | tee -a "$LOG_FILE"
}

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  log "PASS" "$1"
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  log "WARN" "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  log "FAIL" "$1"
}

latest_migration_state() {
  find state/migrations -type f -name '*.state' 2>/dev/null | sort | tail -1
}

check_migration_state() {
  local file
  file="$(latest_migration_state)"

  if [[ "$FAIL_CHECK" == "migration" ]]; then
    fail "Injected migration state failure"
  elif [[ -n "$file" ]] && grep -q '^status=SUCCESS$' "$file"; then
    pass "Controller migration state is successful"
  else
    fail "Controller migration state is unavailable or unsuccessful"
  fi
}

check_branch_state() {
  local file="state/onboarding/${BRANCH_ID}.state"

  if [[ "$FAIL_CHECK" == "branch" ]]; then
    fail "Injected branch state failure"
  elif [[ -f "$file" ]] && grep -q '^status=SUCCESS$' "$file"; then
    pass "Branch ${BRANCH_ID} onboarding state is successful"
  else
    fail "Branch ${BRANCH_ID} onboarding state is unavailable or unsuccessful"
  fi
}

check_alb_health() {
  if [[ "$FAIL_CHECK" == "alb" ]]; then
    fail "Simulated ALB target is unhealthy"
  else
    pass "Simulated ALB target is healthy"
  fi
}

check_controller_reachability() {
  if [[ "$FAIL_CHECK" == "controller" ]]; then
    fail "Simulated controller reachability check failed"
  else
    pass "Simulated controller reachability check passed"
  fi
}

check_branch_connectivity() {
  if [[ "$FAIL_CHECK" == "connectivity" ]]; then
    warn "Simulated branch connectivity is degraded"
  else
    pass "Simulated branch connectivity is operational"
  fi
}

write_state() {
  local status="$1"

  cat > "$STATE_FILE" <<STATE
validation_id=${RUN_ID}
branch_id=${BRANCH_ID}
status=${status}
passed=${PASS_COUNT}
warnings=${WARN_COUNT}
failed=${FAIL_COUNT}
updated_at=$(timestamp)
log_file=${LOG_FILE}
STATE
}

: > "$LOG_FILE"

log "INFO" "Starting post-migration validation"

check_migration_state
check_branch_state
check_alb_health
check_controller_reachability
check_branch_connectivity

if (( FAIL_COUNT > 0 )); then
  write_state "FAILED"
  log "ERROR" "Post-migration validation failed"
  exit 1
fi

if (( WARN_COUNT > 0 )); then
  write_state "WARNING"
  log "WARN" "Post-migration validation completed with warnings"
else
  write_state "SUCCESS"
  log "SUCCESS" "Post-migration validation completed successfully"
fi

printf '\nValidation summary\n'
printf '%s\n' '------------------'
printf 'Passed: %s\n' "$PASS_COUNT"
printf 'Warnings: %s\n' "$WARN_COUNT"
printf 'Failed: %s\n' "$FAIL_COUNT"
printf 'State file: %s\n' "$STATE_FILE"
printf 'Log file: %s\n' "$LOG_FILE"
