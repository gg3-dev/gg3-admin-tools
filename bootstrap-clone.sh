#!/bin/bash

# Title: bootstrap-clone.sh
# Purpose: Use staged SSH key to clone .gg3.conf repo securely into new VM

set -e

# Paths
TMP_STAGE_DIR="/tmp/bootstrap-staging"
SSH_KEY_PATH=$(find "$TMP_STAGE_DIR" -name "key.gg3.bootstrap.vm-*" | head -n 1)

if [ -z "$SSH_KEY_PATH" ]; then
  echo "[!] Bootstrap SSH key not found in staging area. Aborting."
  exit 1
fi

echo "[*] Bootstrap SSH Key found: $SSH_KEY_PATH"
echo "[*] Starting Git clone..."

# Clone using temporary key
GIT_SSH_COMMAND="ssh -i $SSH_KEY_PATH" git clone git@github.com:gg3-dev/.gg3.conf.git ~/.gg3.conf

echo "[✓] Git clone successful."

# Reminder
echo
echo "[!] IMPORTANT: After running './install.sh', the /tmp/bootstrap-staging/ folder will be deleted."
echo "[!] Make sure to immediately run:"
echo
echo "    cd ~/.gg3.conf"
echo "    ./install.sh"
echo

exit 0
