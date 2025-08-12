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

BASE_DIR=$(pwd)

relpath() {
  local p="$1"
  # Remove leading ./
  p="${p#./}"
  if [[ "$p" == "$BASE_DIR"* ]]; then
    p="${p#$BASE_DIR/}"
  fi
  printf '%s' "$p"
}

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: log file '$LOG_FILE' not found" >&2
  exit 1
fi

# Collect passed and failed test script paths from the log.
mapfile -t passed_tests < <(grep -E 'Running tests/.+\.sh \.\.\. OK' "$LOG_FILE" | sed -E 's/.*Running (tests\/[^ ]+) \.\.\. OK/\1/' | sort -u)
mapfile -t failed_tests < <(grep -E 'Running tests/.+\.sh \.\.\. failed' "$LOG_FILE" | sed -E 's/.*Running (tests\/[^ ]+) \.\.\. failed/\1/' | sort -u)

# Extract diff commands (classic diff and diff-nums.py variants) from the log so we can
# show the exact comparison command for each failed expected/out pair. We also support
# occasionally misspelled variants like diff-numps.py. Output redirection ('> file.diff')
# is stripped so the command, when copied, shows output in the console.
declare -A diff_cmds
declare -A missing_logs        # failed test -> 1 if its .log file missing
declare -A had_failed_pair     # failed test -> 1 if at least one failed exp/out pair emitted
declare -A no_diff_evidence    # failed test -> 1 if processed but produced no diff evidence
while IFS= read -r _line; do
  # Need both an .expected and a .out reference and either the word 'diff' or 'diff-nums'
  [[ "$_line" == *.expected* && "$_line" == *.out* ]] || continue
  if [[ "$_line" != *diff* && "$_line" != *diff-nums* && "$_line" != *diff-numps* ]]; then
    continue
  fi
  # Strip any output redirection portion ( > something ) to keep command minimal
  sanitized="$_line"
  # Remove everything after an unescaped > (simplistic but sufficient for our logs)
  sanitized=${sanitized%%>*}
  sanitized="${sanitized%%[[:space:]]}" # trim trailing space possibly left
  # Remove '-o file.diff' patterns so output goes to console
  sanitized=$(echo "$sanitized" | sed -E 's/[[:space:]]-o[[:space:]]+[^[:space:]]+//g')
  # Identify first .expected and .out tokens (order agnostic)
  if [[ $sanitized =~ ([^[:space:]]+\.expected) ]] && [[ $sanitized =~ ([^[:space:]]+\.out) ]]; then
    exp_path="${BASH_REMATCH[1]}"
    # second match context lost; re-run for out via separate regex
    if [[ $sanitized =~ ([^[:space:]]+\.out) ]]; then
      out_path="${BASH_REMATCH[1]}"
    fi
    [[ -n "$exp_path" && -n "$out_path" ]] || continue
    # Only record first occurrence per expected file
    key_rel=$(relpath "$exp_path")
    if [[ -z ${diff_cmds[$key_rel]+_} ]]; then
  sanitized_display=$(echo "$sanitized" | sed -E "s#${BASE_DIR}/##g")
  # Remove environment variable prefixes like $MRT_TOOLS/ or ${MRT_TOOLS}/
  sanitized_display=$(echo "$sanitized_display" | sed -E 's#\$\{?MRT_TOOLS\}?/##g')
      # Ensure file arguments appear with proper relative paths (including directories) when original used only basenames
      rel_exp=$(relpath "$exp_path"); rel_out=$(relpath "$out_path")
      base_exp=$(basename "$exp_path"); base_out=$(basename "$out_path")
      # Replace standalone basenames (followed by space or end) with rel paths if different
      if [[ "$rel_exp" != "$base_exp" ]]; then
        sanitized_display="${sanitized_display// $base_exp/ $rel_exp}"
        # Handle start-of-line case
        sanitized_display="${sanitized_display/#$base_exp /$rel_exp }"
      fi
      if [[ "$rel_out" != "$base_out" ]]; then
        sanitized_display="${sanitized_display// $base_out/ $rel_out}"
        sanitized_display="${sanitized_display/#$base_out /$rel_out }"
      fi
  # Normalize tool path prefixes so they are executable from repo root
  sanitized_display=$(echo "$sanitized_display" | sed -E 's#(^|[[:space:]])diff-nums\.py#\1tools/diff-nums.py#g')
  sanitized_display=$(echo "$sanitized_display" | sed -E 's#(^|[[:space:]])diff\.sh#\1tools/diff.sh#g')
  diff_cmds["$key_rel"]="$sanitized_display"
    fi
  fi
done < "$LOG_FILE"

# Also scan individual test scripts and their *.log counterparts for additional diff
# commands (including diff-nums.py / diff-numps.py) that may not appear in the
# aggregate log. This helps surface the exact invocation used inside the test.
parse_additional_diff_cmds() {
  local -n _scripts_ref=$1
  local script file dir line sanitized exp_path out_path
  for script in "${_scripts_ref[@]}"; do
    [[ -f "$script" ]] || continue
    dir=$(dirname "$script")
    for file in "$script" "$script.log"; do
      [[ -f "$file" ]] || continue
      while IFS= read -r line; do
        [[ "$line" == *.expected* && "$line" == *.out* ]] || continue
        if [[ "$line" != *diff* && "$line" != *diff-nums* && "$line" != *diff-numps* ]]; then
          continue
        fi
  sanitized=${line%%>*}
  sanitized="${sanitized%%[[:space:]]}"
  sanitized=$(echo "$sanitized" | sed -E 's/[[:space:]]-o[[:space:]]+[^[:space:]]+//g')
        # Capture first expected and out tokens; order agnostic
        exp_path=""
        out_path=""
        if [[ $sanitized =~ ([^[:space:]]+\.expected) ]]; then
          exp_path="${BASH_REMATCH[1]}"
        fi
        if [[ $sanitized =~ ([^[:space:]]+\.out) ]]; then
          out_path="${BASH_REMATCH[1]}"
        fi
        [[ -n "$exp_path" && -n "$out_path" ]] || continue
        # Normalize relative paths relative to script directory
        [[ "$exp_path" == /* ]] || exp_path="$dir/${exp_path#./}"
        [[ "$out_path" == /* ]] || out_path="$dir/${out_path#./}"
        # Only set if not already present to keep the first occurrence
        key_rel=$(relpath "$exp_path")
        if [[ -z ${diff_cmds[$key_rel]+_} ]]; then
          sanitized_display=$(echo "$sanitized" | sed -E "s#${BASE_DIR}/##g")
          sanitized_display=$(echo "$sanitized_display" | sed -E 's#\$\{?MRT_TOOLS\}?/##g')
          rel_exp=$(relpath "$exp_path"); rel_out=$(relpath "$out_path")
          base_exp=$(basename "$exp_path"); base_out=$(basename "$out_path")
          if [[ "$rel_exp" != "$base_exp" ]]; then
            sanitized_display="${sanitized_display// $base_exp/ $rel_exp}"
            sanitized_display="${sanitized_display/#$base_exp /$rel_exp }"
          fi
            if [[ "$rel_out" != "$base_out" ]]; then
            sanitized_display="${sanitized_display// $base_out/ $rel_out}"
            sanitized_display="${sanitized_display/#$base_out /$rel_out }"
          fi
          sanitized_display=$(echo "$sanitized_display" | sed -E 's#(^|[[:space:]])diff-nums\.py#\1tools/diff-nums.py#g')
          sanitized_display=$(echo "$sanitized_display" | sed -E 's#(^|[[:space:]])diff\.sh#\1tools/diff.sh#g')
          diff_cmds["$key_rel"]="$sanitized_display"
        fi
      done < "$file"
    done
  done
}

# Enrich diff_cmds from passed and failed test scripts/logs
parse_additional_diff_cmds passed_tests
parse_additional_diff_cmds failed_tests

# Record missing per-test logs for failed tests (after augmentation parsing)
for t in "${failed_tests[@]}"; do
  [[ -f "$t.log" ]] || missing_logs["$t"]=1
done

if [[ ${#passed_tests[@]} -eq 0 ]]; then
  echo "No passed tests found to process." >&2
fi

# Number of diff output lines to embed for failed examples
MAX_DIFF_LINES=10

# Run the appropriate diff command (captured or generic) and emit first N lines as commented snippet
produce_diff_snippet() {
  local exp_rel="$1" out_rel="$2" key_rel cmd snippet total_lines head_lines
  key_rel="$exp_rel"
  if [[ -n ${diff_cmds[$key_rel]+_} ]]; then
    cmd="${diff_cmds[$key_rel]}"
  else
    cmd="diff -u $exp_rel $out_rel"
  fi
  snippet=$(bash -c "$cmd" 2>&1 || true)
  [[ -n "$snippet" ]] || { echo "# | (no diff output)"; return; }
  total_lines=$(printf '%s\n' "$snippet" | wc -l | tr -d ' ')
  head_lines=$(printf '%s\n' "$snippet" | head -n "${MAX_DIFF_LINES}")
  while IFS= read -r line; do
    printf '# | %s\n' "$line"
  done <<< "$head_lines"
  if (( total_lines > MAX_DIFF_LINES )); then
    echo "# | ... (${total_lines} total lines, truncated)"
  fi
}

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
    local emitted_any=0
    for out_file in "$test_dir"/*.out; do
      [[ -f "$out_file" ]] || continue
      local exp_file="${out_file%.out}.expected"
      [[ -f "$exp_file" ]] || continue
      if [[ "$mode" == active ]]; then
        rel_exp=$(relpath "$exp_file"); rel_out=$(relpath "$out_file")
        printf 'backup_and_update %q %q\n' "$rel_exp" "$rel_out" >> "$outfile"
      else
        rel_exp=$(relpath "$exp_file"); rel_out=$(relpath "$out_file")
        # For failed listing, include only if we have a captured diff command OR a non-empty .diff artifact.
        local diff_file="${exp_file%.expected}.diff"
        key_rel=$(relpath "$exp_file")
        if [[ -z ${diff_cmds[$key_rel]+_} && ! ( -s "$diff_file" ) ]]; then
          continue  # Skip: no evidence this pair was actually diffed by this failing script
        fi
        emitted_any=1
        had_failed_pair["$test_path"]=1
        printf '# FAILED: %s -> %s\n' "$test_path" "$rel_exp" >> "$outfile"
        # If we saw an original diff command referencing this expected file, include it.
        if [[ -n ${diff_cmds[$key_rel]+_} ]]; then
          printf '# diff: %s\n' "${diff_cmds[$key_rel]}" >> "$outfile"
        else
          printf '# diff (reconstruct): diff -u %q %q\n' "$rel_exp" "$rel_out" >> "$outfile"
        fi
        produce_diff_snippet "$rel_exp" "$rel_out" >> "$outfile"
        printf '# backup_and_update %q %q\n' "$rel_exp" "$rel_out" >> "$outfile"
      fi
    done
    shopt -u nullglob
    if [[ "$mode" == commented && $emitted_any -eq 0 ]]; then
      # Mark lack of diff evidence (unless already had a pair earlier in same test_dir loop)
      if [[ -z ${had_failed_pair[$test_path]+_} ]]; then
        no_diff_evidence["$test_path"]=1
      fi
    fi
  done
}

# Prepare temporary file fragments
active_tmp=$(mktemp)
commented_tmp=$(mktemp)

collect_pairs PASSED passed_tests "$active_tmp" active
collect_pairs FAILED failed_tests "$commented_tmp" commented

pair_count=$(grep -c '^backup_and_update ' "$active_tmp" || true)
failed_pair_count=$(grep -c '^# backup_and_update ' "$commented_tmp" || true)

# Collect existing pairs (exp|out) to avoid duplicates when adding cross-file pairs
existing_pairs_tmp=$(mktemp)
grep '^backup_and_update ' "$active_tmp" | awk '{print $2"|"$3}' > "$existing_pairs_tmp" || true
grep '^# backup_and_update ' "$commented_tmp" | awk '{print $3"|"$4}' >> "$existing_pairs_tmp" || true

# Number of diff output lines to embed for failed examples

# Function to add cross-file pairs discovered in test scripts where the .out and .expected
# filenames do not share the same basename (e.g. batched.out vs scores.expected)
add_cross_file_pairs() {
  local status="$1"   # PASSED or FAILED
  shift
  local -n scripts_ref=$1
  local target_file="$2" # active or commented temp file path
  local mode="$3"        # active or commented
  local script
  for script in "${scripts_ref[@]}"; do
    [[ -f "$script" ]] || continue
    local dir
    dir=$(dirname "$script")
    # Parse diff-nums.py invocation lines
    while IFS= read -r line; do
      # Skip if line doesn't reference diff-nums.py
      [[ "$line" == *diff-nums.py* ]] || continue
      # Strip output redirection and options, capture last two positional tokens ending with .out/.expected in either order
      # We first tokenize the line
      local tokens=()
      while read -r tok; do tokens+=("$tok"); done < <(echo "$line" | sed -E 's/>.*//' | tr ' ' '\n')
      local oFile="" eFile=""
      local t
      for ((i=0;i<${#tokens[@]};++i)); do
        t="${tokens[$i]}"
        [[ "$t" == -* ]] && continue # option
        if [[ "$t" == *.out ]]; then oFile="$t"; fi
        if [[ "$t" == *.expected ]]; then eFile="$t"; fi
      done
      [[ -n "$oFile" && -n "$eFile" ]] || continue
      # Prepend directory if relative
      [[ "$oFile" == /* ]] || oFile="$dir/$oFile"
      [[ "$eFile" == /* ]] || eFile="$dir/$eFile"
      # Skip if sibling basenames match (already handled) or pair already exists
      if [[ "${oFile%.out}.expected" == "$eFile" ]]; then continue; fi
      local key="$eFile|$oFile"
      if grep -Fqx "$key" "$existing_pairs_tmp"; then continue; fi
      echo "$key" >> "$existing_pairs_tmp"
      if [[ "$mode" == active ]]; then
        rel_e=$(relpath "$eFile"); rel_o=$(relpath "$oFile")
        printf 'backup_and_update %q %q # cross-file\n' "$rel_e" "$rel_o" >> "$target_file"
      else
        rel_e=$(relpath "$eFile"); rel_o=$(relpath "$oFile")
        printf '# FAILED (cross-file): %s -> %s <= %s\n' "$script" "$rel_e" "$rel_o" >> "$target_file"
        key_rel=$(relpath "$eFile")
        if [[ -n ${diff_cmds[$key_rel]+_} ]]; then
          printf '# diff: %s\n' "${diff_cmds[$key_rel]}" >> "$target_file"
        else
          printf '# diff (reconstruct): diff -u %q %q\n' "$rel_e" "$rel_o" >> "$target_file"
        fi
        produce_diff_snippet "$rel_e" "$rel_o" >> "$target_file"
        printf '# backup_and_update %q %q # cross-file\n' "$rel_e" "$rel_o" >> "$target_file"
      fi
    done < "$script"
  done
}

# Append cross-file pairs for passed and failed tests
add_cross_file_pairs PASSED passed_tests "$active_tmp" active
add_cross_file_pairs FAILED failed_tests "$commented_tmp" commented

# Append summary for failed tests with no diff evidence or missing logs
summary_tmp=$(mktemp)
{
  any_entry=0
  for t in "${failed_tests[@]}"; do
    if [[ -n ${had_failed_pair[$t]+_} ]]; then
      continue
    fi
    # Determine notes without triggering set -u (use +_ guards)
    status_notes=()
    [[ -n ${missing_logs[$t]+_} ]] && status_notes+=("missing-log")
    [[ -n ${no_diff_evidence[$t]+_} ]] && status_notes+=("no-diff-lines")
    [[ ${#status_notes[@]} -eq 0 ]] && status_notes+=("unspecified")
    if [[ $any_entry -eq 0 ]]; then
      echo "# === FAILED TESTS WITHOUT DIFF EVIDENCE SUMMARY ==="
      any_entry=1
    fi
    printf '# SUMMARY: %s [%s]\n' "$t" "${status_notes[*]}"
  done
  if [[ $any_entry -eq 1 ]]; then
    echo "# === END NO DIFF EVIDENCE SUMMARY ==="
  fi
} >> "$summary_tmp"

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

# Append summary (missing logs / no diff evidence)
if [[ -f "$summary_tmp" ]]; then
  cat "$summary_tmp" >> "$OUT_SCRIPT"
  echo >> "$OUT_SCRIPT"
fi

cat >> "$OUT_SCRIPT" <<'EOF'
echo "Update complete: $updated updated, $skipped skipped." >&2
EOF

chmod +x "$OUT_SCRIPT"
echo "Generated $OUT_SCRIPT with $pair_count active pairs and $failed_pair_count commented candidate pairs." >&2
rm -f "$active_tmp" "$commented_tmp" "$summary_tmp"
