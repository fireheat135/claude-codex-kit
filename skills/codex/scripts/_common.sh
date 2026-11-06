# shellcheck shell=bash
# Shared helpers for codex-* scripts. Portable: Linux (GNU) and macOS (BSD, bash 3.2).

# run_timeout SECONDS CMD... — timeout / gtimeout (Homebrew coreutils) / perl alarm fallback.
run_timeout() {
  local secs=$1; shift
  if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"
  else perl -e 'alarm shift; exec @ARGV' "$secs" "$@"; fi
}

# abspath PATH — absolute path for a file that may not exist yet (creates its directory).
abspath() {
  local dir; dir=$(dirname "$1"); mkdir -p "$dir"
  printf '%s/%s\n' "$(cd "$dir" && pwd)" "$(basename "$1")"
}

need_login() {
  codex login status >/dev/null 2>&1 && return 0
  echo "Codex is not logged in. Run: codex login --device-auth  (or: codex login)" >&2
  return 2
}
