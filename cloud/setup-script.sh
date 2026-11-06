#!/bin/bash
# Paste into: Claude Code cloud environment -> Edit -> Setup script. Runs on every fresh container.
set -e
[ -d ~/claude-codex-kit ] || git clone --depth 1 https://github.com/fireheat135/claude-codex-kit ~/claude-codex-kit
~/claude-codex-kit/install.sh --cloud
apt-get install -y shellcheck || true   # optional tools: never fail the setup
# Per-repository steps go below, guarded, e.g.:
# if [ -d game-lab ]; then (cd game-lab && npm ci); fi
