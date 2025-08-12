#!/usr/bin/env bash

# Generate a helper script that updates *.expected files with the current *.out
# results for all tests that PASSED in a given previous.log.
#
# Rationale: When migrating to new hardware (e.g. different GPU/CPU architecture),
# small numeric differences are accepted and new outputs become the canonical
# expected values for passing tests.
#
# Usage:
#   tools/gen-update-expected.sh [previous.log] [output-script]
# Example:
#   tools/gen-update-expected.sh previous.log tools/update-expected-from-previous.sh
#   bash tools/update-expected-from-previous.sh   # performs the update
#
# The produced updater script will:
#  - Create a timestamped backup directory: expected-backup-<timestamp>
#  - For every *.out that has a sibling *.expected, copy the original *.expected
#    into the backup (preserving directory structure) once, then overwrite it
#    with the current *.out content.
#  - Skip pairs where the *.expected file does not exist.
#
# Notes:
#  - Only tests explicitly marked as OK in the provided log are auto-updated.
#  - FAILED tests are also listed, but their update commands are commented out.
#    Manually inspect and uncomment if you decide to accept those outputs.
#  - No filtering on test type; ALL passing tests' expected pairs are updated if present.
#  - Idempotent: running the generated updater multiple times will refresh expected
#    values again (only the first run preserves originals in its own backup dir).

set -euo pipefail

LOG_FILE="${1:-previous.log}"
OUT_SCRIPT="${2:-update-expected-from-previous.sh}"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: log file '$LOG_FILE' not found" >&2
  exit 1
fi

# Collect passed and failed test script paths from the log.
mapfile -t passed_tests < <(grep -E 'Running tests/.+\.sh \.\.\. OK' "$LOG_FILE" | sed -E 's/.*Running (tests\/[^ ]+) \.\.\. OK/\1/' | sort -u)
mapfile -t failed_tests < <(grep -E 'Running tests/.+\.sh \.\.\. failed' "$LOG_FILE" | sed -E 's/.*Running (tests\/[^ ]+) \.\.\. failed/\1/' | sort -u)

# Extract diff commands from the log so we can show the exact comparison command
# for each failed expected/out pair. We attempt to capture lines that look like:
#   diff -u path/file.expected path/file.out > path/file.diff
# or variants with additional flags. We index them by the .expected path.
declare -A diff_cmds
while IFS= read -r _line; do
  # Fast filter to lines containing '.expected' and '.out' and the word 'diff'
  [[ "$_line" == *diff* && "$_line" == *.expected* && "$_line" == *.out* ]] || continue
  # Regex to capture the expected and out file (first occurrence) after 'diff' and its flags
  if [[ $_line =~ diff[[:space:][:alnum:][:punct:]]*([^[:space:]]+\.expected)[[:space:]]+([^[:space:]]+\.out) ]]; then
    exp_path="${BASH_REMATCH[1]}"
    out_path="${BASH_REMATCH[2]}"
    # Only record the first occurrence per expected file to avoid noise
    if [[ -z ${diff_cmds[$exp_path]+_} ]]; then
      diff_cmds["$exp_path"]="$_line"
    fi
  fi
done < "$LOG_FILE"

if [[ ${#passed_tests[@]} -eq 0 ]]; then
  echo "No passed tests found to process." >&2
fi

# Helper to collect exp/out pairs for a given list of tests.
collect_pairs() {
  local tag="$1"; shift
  local -n _tests_ref=$1
  local outfile="$2"
  local mode="$3"   # "active" or "commented"
  for test_path in "${_tests_ref[@]}"; do
    local test_dir
    test_dir=$(dirname "$test_path")
    [[ -d "$test_dir" ]] || continue
    shopt -s nullglob
    for out_file in "$test_dir"/*.out; do
      [[ -f "$out_file" ]] || continue
      local exp_file="${out_file%.out}.expected"
      [[ -f "$exp_file" ]] || continue
      if [[ "$mode" == active ]]; then
        printf 'backup_and_update %q %q\n' "$exp_file" "$out_file" >> "$outfile"
      else
        printf '# FAILED: %s -> %s\n' "$test_path" "$exp_file" >> "$outfile"
        # If we saw an original diff command referencing this expected file, include it.
        if [[ -n ${diff_cmds[$exp_file]+_} ]]; then
          printf '# diff: %s\n' "${diff_cmds[$exp_file]}" >> "$outfile"
        else
          # Provide a generic diff command as a fallback.
            printf '# diff (reconstruct): diff -u %q %q > %q.diff\n' "$exp_file" "$out_file" "${exp_file%.expected}" >> "$outfile"
        fi
        printf '# backup_and_update %q %q\n' "$exp_file" "$out_file" >> "$outfile"
      fi
    done
    shopt -u nullglob
  done
}

# Prepare temporary file fragments
active_tmp=$(mktemp)
commented_tmp=$(mktemp)

collect_pairs PASSED passed_tests "$active_tmp" active
collect_pairs FAILED failed_tests "$commented_tmp" commented

pair_count=$(grep -c '^backup_and_update ' "$active_tmp" || true)
failed_pair_count=$(grep -c '^# backup_and_update ' "$commented_tmp" || true)

cat > "$OUT_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Auto-generated script: updates *.expected files from current *.out artifacts.
# Sections:
#  1) Active updates for PASSED tests.
#  2) Commented out candidate updates for FAILED tests (manual review required).
# Generated by gen-update-expected.sh.

timestamp=$(date +%Y%m%d-%H%M%S)
backup_root="expected-backup-${timestamp}"
echo "Creating backup at: $backup_root" >&2
mkdir -p "$backup_root"

updated=0
skipped=0

backup_and_update() {
  # Usage: backup_and_update <expected-file> <out-file>
  local exp="$1"
  local out="$2"
  if [[ ! -f "$exp" || ! -f "$out" ]]; then
    echo "[skip] Missing file for pair: $exp | $out" >&2
  ((++skipped))
    return
  fi
  local dest="$backup_root/$exp"
  local dest_dir
  dest_dir=$(dirname "$dest")
  if [[ ! -f "$dest" ]]; then
    mkdir -p "$dest_dir"
    cp -p "$exp" "$dest"
  fi
  cp -p "$out" "$exp"
  echo "[upd] $exp <- $out" >&2
  ((++updated))
}

# === BEGIN PASSED TEST UPDATES ===
EOF

# Ensure newline separation before inserting active pairs
echo >> "$OUT_SCRIPT"

cat "$active_tmp" >> "$OUT_SCRIPT"

echo -e "# === END PASSED TEST UPDATES ===\n" >> "$OUT_SCRIPT"

echo -e "# === BEGIN FAILED TEST CANDIDATES (commented) ===" >> "$OUT_SCRIPT"
cat "$commented_tmp" >> "$OUT_SCRIPT"
echo -e "# === END FAILED TEST CANDIDATES ===\n" >> "$OUT_SCRIPT"

cat >> "$OUT_SCRIPT" <<'EOF'
echo "Update complete: $updated updated, $skipped skipped." >&2
EOF

chmod +x "$OUT_SCRIPT"
echo "Generated $OUT_SCRIPT with $pair_count active pairs and $failed_pair_count commented candidate pairs." >&2
rm -f "$active_tmp" "$commented_tmp"
