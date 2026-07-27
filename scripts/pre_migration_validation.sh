#!/usr/bin/env bash
set -uo pipefail

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
  printf '[PASS] %s\n' "$1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  printf '[FAIL] %s\n' "$1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

warn() {
  printf '[WARN] %s\n' "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

check_command() {
  local command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    pass "$command_name is installed"
  else
    fail "$command_name is not installed"
  fi
}

printf '%s\n' 'VCP to AWS Pre-Migration Validation'
printf '%s\n\n' '==================================='

check_command terraform
check_command git
check_command python3

if command -v aws >/dev/null 2>&1; then
  pass "AWS CLI is installed"

  if aws sts get-caller-identity >/dev/null 2>&1; then
    pass "AWS credentials are valid"
  else
    warn "AWS credentials are unavailable or invalid"
  fi
else
  warn "AWS CLI is not installed"
fi

required_files=(
  "terraform/main.tf"
  "terraform/providers.tf"
  "terraform/variables.tf"
  "terraform/outputs.tf"
  "terraform/versions.tf"
  "architecture/legacy/README.md"
  "architecture/target/README.md"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    pass "$file exists"
  else
    fail "$file is missing"
  fi
done

if terraform -chdir=terraform fmt -check >/dev/null 2>&1; then
  pass "Terraform files are formatted"
else
  fail "Terraform formatting check failed"
fi

if terraform -chdir=terraform validate >/dev/null 2>&1; then
  pass "Terraform configuration is valid"
else
  fail "Terraform validation failed"
fi

if git diff --quiet && git diff --cached --quiet; then
  pass "Git working tree has no uncommitted changes"
else
  warn "Git working tree contains uncommitted changes"
fi

printf '\nValidation summary: %s passed, %s warnings, %s failed\n' \
  "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

if (( FAIL_COUNT > 0 )); then
  exit 1
fi

exit 0
