#!/usr/bin/env bash
# claude-codex-kit installer. Idempotent: safe to re-run (e.g. after `git pull`).
# Usage: ./install.sh [--cloud] [--with-agmsg] [--bin DIR]
#   (default)     local machine (macOS/Linux): commands go to ~/.local/bin
#   --cloud       Claude Code cloud container: commands go to /usr/local/bin
#   --with-agmsg  also install agmsg (cross-agent messaging; needs sqlite3)
#   --bin DIR     where to link the codex-* commands
# Existing files that would be replaced are moved to ~/.claude-codex-kit-backup/<timestamp>/. Nothing is deleted.
set -euo pipefail
KIT=$(cd "$(dirname "$0")" && pwd)
mode=local; with_agmsg=0; bin=""
while [ $# -gt 0 ]; do
  case $1 in
    --cloud) mode=cloud; shift ;;
    --with-agmsg) with_agmsg=1; shift ;;
    --bin) bin=$2; shift 2 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 64 ;;
  esac
done
if [ -z "$bin" ]; then
  if [ "$mode" = cloud ]; then bin=/usr/local/bin; else bin=$HOME/.local/bin; fi
fi

say() { printf '  %s\n' "$*"; }
# link SRC DEST — symlink DEST -> SRC. An existing real file/dir at DEST is moved to BACKUP first
# (outside the skills folders, so a backed-up skill is never loaded as a duplicate).
BACKUP="$HOME/.claude-codex-kit-backup/$(date +%Y%m%d%H%M%S)"
link() {
  local src=$1 dest=$2
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP"; mv "$dest" "$BACKUP/$(echo "${dest#"$HOME"/}" | sed 's#^\.##; s#/\.#/#g' | tr '/' '_')"
    say "backed up existing $dest -> $BACKUP"
  fi
  ln -sfn "$src" "$dest"; say "$dest -> $src"
}

echo "claude-codex-kit: installing ($mode)"
if ! command -v codex >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then npm i -g @openai/codex
  else say "Codex CLI not found and npm is missing: install Node.js or run 'brew install codex', then re-run."; fi
fi

link "$KIT/home/CLAUDE.md" "$HOME/.claude/CLAUDE.md"   # shared rules for Claude ...
link "$KIT/home/CLAUDE.md" "$HOME/.codex/AGENTS.md"    # ... and Codex (same file)
link "$KIT/skills/codex" "$HOME/.claude/skills/codex"  # skill for Claude Code
link "$KIT/skills/codex" "$HOME/.agents/skills/codex"  # skill for Codex (Agent Skills standard)
for s in codex-run codex-image codex-review; do link "$KIT/skills/codex/scripts/$s" "$bin/$s"; done
case ":$PATH:" in *":$bin:"*) ;; *) say "NOTE: add to your shell profile: export PATH=\"$bin:\$PATH\"" ;; esac

if [ "$with_agmsg" = 1 ]; then
  command -v sqlite3 >/dev/null 2>&1 || say "agmsg needs sqlite3 (macOS has it; Debian/Ubuntu: apt-get install -y sqlite3)"
  if command -v agmsg >/dev/null 2>&1; then say "agmsg already installed"
  else npm i -g agmsg && agmsg install --cmd agmsg; fi
  say "agmsg: restart Claude Code / Codex, then run /agmsg (Claude) or \$agmsg (Codex) and join the same team"
fi

if codex login status >/dev/null 2>&1; then say "Codex: logged in"
else say "Codex: not logged in -> run 'codex login' (or 'codex login --device-auth' on a remote machine)"; fi
echo "done."
