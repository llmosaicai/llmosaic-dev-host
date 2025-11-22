#!/usr/bin/env bash
set -euo pipefail

SSH_USER="${SSH_USER:-dev}"

# Generate host keys if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

# authorized_keys provided via read-only Secret at /etc/ssh/authorized_keys

exec /usr/sbin/sshd -D -e

