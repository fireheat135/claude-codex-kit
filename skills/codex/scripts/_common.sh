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

# safe_workdir DIR — refuse to give Codex write access to $HOME or / (it could edit any file there).
# Override with CODEX_ALLOW_BROAD_WORKDIR=1 only if you really mean it.
safe_workdir() {
  local d; d=$(cd "$1" && pwd -P) || return 1
  if [ "${CODEX_ALLOW_BROAD_WORKDIR:-0}" != 1 ] && { [ "$d" = / ] || [ "$d" = "$(cd "$HOME" && pwd -P)" ]; }; then
    echo "Refusing to let Codex write in $d (too broad). cd into a project folder or pass -C <dir>." >&2
    return 3
  fi
}

need_login() {
  codex login status >/dev/null 2>&1 && return 0
  echo "Codex is not logged in. Run: codex login --device-auth  (or: codex login)" >&2
  return 2
}
