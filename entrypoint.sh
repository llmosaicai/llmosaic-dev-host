#!/usr/bin/env bash
set -euo pipefail

SSH_USER="${SSH_USER:-dev}"

# Generate host keys if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

# authorized_keys provided via read-only Secret at /etc/ssh/authorized_keys

# Convenience symlinks for the dev user
WS_BASE="/workspace/repos"
EX_SRC="$WS_BASE/llmosaic-rag/assets/examples"
DEV_HOME="/home/${SSH_USER}"
if [ -d "$WS_BASE" ]; then
  # Symlink ~/repos -> /workspace/repos
  if [ ! -e "$DEV_HOME/repos" ]; then
    ln -s "$WS_BASE" "$DEV_HOME/repos" || true
  fi
  # Symlink ~/examples -> llmosaic-rag/assets/examples when present
  if [ -d "$EX_SRC" ] && [ ! -e "$DEV_HOME/examples" ]; then
    ln -s "$EX_SRC" "$DEV_HOME/examples" || true
  fi
fi
chown -h ${SSH_USER}:${SSH_USER} "$DEV_HOME"/repos "$DEV_HOME"/examples 2>/dev/null || true

exec /usr/sbin/sshd -D -e
