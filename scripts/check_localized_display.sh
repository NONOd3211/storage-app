#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Checking for potential non-localized display usage..."

violations=0

check_pattern() {
  local pattern="$1"
  local label="$2"
  local out
  out="$(rg -n "$pattern" lib/screens lib/widgets || true)"
  if [[ -n "$out" ]]; then
    echo
    echo "[${label}]"
    echo "$out"
    violations=1
  fi
}

# Risky patterns for direct display of raw location fields.
check_pattern "Text\\(\\s*item\\.storageLocation\\s*\\)" "raw item.storageLocation in Text"
check_pattern "\\$\\{item\\.storageLocation\\}" "raw item.storageLocation interpolation"
check_pattern "Text\\(\\s*location\\.name\\s*\\)" "raw location.name in Text"
check_pattern "Text\\(\\s*selectedLocation\\.name\\s*\\)" "raw selectedLocation.name in Text"

if [[ "$violations" -ne 0 ]]; then
  echo
  echo "Found potential issues. Prefer:"
  echo "  - item.localizedStorageLocationName(l10n)"
  echo "  - location.localizedName(l10n)"
  exit 1
fi

echo "No obvious raw display issues found."
