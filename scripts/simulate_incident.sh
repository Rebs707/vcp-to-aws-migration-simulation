#!/usr/bin/env bash
set -uo pipefail

INCIDENT_TYPE="${INCIDENT_TYPE:-controller_unreachable}"
INCIDENT_ID="${INCIDENT_ID:-incident-$(date -u +%Y%m%dT%H%M%SZ)}"
BRANCH_ID="${BRANCH_ID:-branch-001}"

LOG_DIR="logs/incidents"
STATE_DIR="state/incidents"
LOG_FILE="${LOG_DIR}/${INCIDENT_ID}.log"
STATE_FILE="${STATE_DIR}/${INCIDENT_ID}.state"

mkdir -p "$LOG_DIR" "$STATE_DIR"

timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

log() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(timestamp)" "$level" "$message" | tee -a "$LOG_FILE"
}

write_state() {
  local severity="$1"
  local impact="$2"
  local action="$3"
  local outcome="$4"

  cat > "$STATE_FILE" <<STATE
incident_id=${INCIDENT_ID}
incident_type=${INCIDENT_TYPE}
branch_id=${BRANCH_ID}
severity=${severity}
impact=${impact}
action=${action}
outcome=${outcome}
updated_at=$(timestamp)
log_file=${LOG_FILE}
STATE
}

simulate_controller_unreachable() {
  log "ERROR" "AWS controller is unreachable"
  log "INFO" "Console access is required from the field engineer"
  log "INFO" "VCP platform remains unchanged"
  log "INFO" "Rollback is not required"
  write_state "HIGH" "branch_onboarding_blocked" "request_console_access" "RESCHEDULE"
}

simulate_branch_onboarding_failure() {
  log "ERROR" "Branch onboarding failed for ${BRANCH_ID}"
  log "INFO" "Controller migration remains successful"
  log "INFO" "Branch configuration requires investigation"
  write_state "MEDIUM" "single_branch_unavailable" "investigate_onboarding" "FAILED"
}

simulate_alb_unhealthy() {
  log "ERROR" "ALB target health check failed"
  log "INFO" "Controller service requires health validation"
  log "INFO" "Migration success cannot be confirmed"
  write_state "HIGH" "controller_service_unavailable" "validate_target_health" "FAILED"
}

simulate_partial_connectivity() {
  log "WARN" "Branch connectivity is degraded"
  log "INFO" "Control tunnel is established but routing is incomplete"
  log "INFO" "Rollback decision requires impact assessment"
  write_state "MEDIUM" "partial_connectivity" "investigate_routing" "PARTIAL"
}

simulate_rollback_required() {
  log "CRITICAL" "Migration introduced a service-impacting change"
  log "INFO" "Previous VCP configuration must be restored"
  log "INFO" "Issue report is required"
  write_state "CRITICAL" "service_outage" "execute_rollback" "ROLLBACK"
}

: > "$LOG_FILE"

log "INFO" "Starting incident simulation"
log "INFO" "Incident ID: ${INCIDENT_ID}"
log "INFO" "Incident type: ${INCIDENT_TYPE}"

case "$INCIDENT_TYPE" in
  controller_unreachable)
    simulate_controller_unreachable
    ;;
  branch_onboarding_failure)
    simulate_branch_onboarding_failure
    ;;
  alb_unhealthy)
    simulate_alb_unhealthy
    ;;
  partial_connectivity)
    simulate_partial_connectivity
    ;;
  rollback_required)
    simulate_rollback_required
    ;;
  *)
    log "ERROR" "Unsupported incident type: ${INCIDENT_TYPE}"
    exit 1
    ;;
esac

log "SUCCESS" "Incident simulation completed"

printf '\nIncident summary\n'
printf '%s\n' '----------------'
printf 'Incident ID: %s\n' "$INCIDENT_ID"
printf 'Incident type: %s\n' "$INCIDENT_TYPE"
printf 'State file: %s\n' "$STATE_FILE"
printf 'Log file: %s\n' "$LOG_FILE"
