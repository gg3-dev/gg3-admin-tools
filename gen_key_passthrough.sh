#!/bin/bash

# Title: gen_key_passthrough.sh
# Purpose: Securely generate a bootstrap SSH key, assign it to a VM based on hostname,
# transfer it, and clean up locally after transfer.

set -e

# Define paths
ADMIN_LOG_DIR="$HOME/admin-logs"
TMP_STAGE_DIR="/tmp/bootstrap-staging"
SSH_DIR="$HOME/.ssh"

# Create admin log directory if not exists
mkdir -p "$ADMIN_LOG_DIR"

# Timestamp for logging
TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
LOG_FILE="$ADMIN_LOG_DIR/bootstrap-$TIMESTAMP.log"

# Welcome message
echo "========================================"
echo "GG3 Bootstrap Key Generator (Admin Mode)"
echo "========================================"
echo

# Prompt for VM connection info
read -rp "Enter target VM IP address: " VM_IP
read -rp "Enter SSH username for VM: " VM_USER

# Attempt to retrieve VM hostname
echo "Connecting to $VM_IP to retrieve hostname..."

if ! VM_HOSTNAME=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$VM_USER@$VM_IP" "hostname"); then
  echo "[!] Failed to connect to VM or retrieve hostname. Aborting."
  exit 1
fi

echo "[+] Detected VM hostname: $VM_HOSTNAME"
echo

# Prompt to use detected hostname or custom
read -rp "Use detected hostname '$VM_HOSTNAME' for key naming? (Y/n): " USE_DETECTED
USE_DETECTED=${USE_DETECTED:-Y}

if [[ "$USE_DETECTED" =~ ^[Nn]$ ]]; then
    read -rp "Enter custom hostname label (no spaces): " CUSTOM_HOSTNAME
    FINAL_HOSTNAME="$CUSTOM_HOSTNAME"
else
    FINAL_HOSTNAME="$VM_HOSTNAME"
fi

# Define key filenames
KEY_NAME="key.gg3.bootstrap.vm-$FINAL_HOSTNAME"
PRIVATE_KEY_PATH="$SSH_DIR/$KEY_NAME"
PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"

# Safety check
if [[ -f "$PRIVATE_KEY_PATH" ]]; then
  echo "[!] Key $PRIVATE_KEY_PATH already exists. Aborting to prevent overwrite."
  exit 1
fi

# Generate SSH key
ssh-keygen -t ed25519 -C "$KEY_NAME" -f "$PRIVATE_KEY_PATH"
chmod 600 "$PRIVATE_KEY_PATH"

# Prepare temp staging folder
mkdir -p "$TMP_STAGE_DIR"
cp "$PRIVATE_KEY_PATH" "$TMP_STAGE_DIR/"
cp "$PUBLIC_KEY_PATH" "$TMP_STAGE_DIR/"

# Create SSH config entry snippet
cat <<EOF > "$TMP_STAGE_DIR/bootstrap-ssh-entry.txt"
Host github.com-bootstrap-vm-$FINAL_HOSTNAME
    HostName github.com
    User git
    IdentityFile ~/.ssh/$KEY_NAME
    IdentitiesOnly yes
EOF

# Create a small log file for VM to import
cat <<EOF > "$TMP_STAGE_DIR/bootstrap-keygen.log"
========================================
[Admin: $(hostname -s)]
Generated bootstrap key for VM: $FINAL_HOSTNAME
Key Name: $KEY_NAME
Timestamp: $(date)
========================================
EOF

# Copy the bootstrap-clone helper script into the staging folder
LOCAL_CLONE_SCRIPT_PATH="$HOME/admin-tools/bootstrap-clone.sh"  # Adjust if stored elsewhere

if [ -f "$LOCAL_CLONE_SCRIPT_PATH" ]; then
    echo "[*] Including bootstrap-clone.sh in staging..."
    cp "$LOCAL_CLONE_SCRIPT_PATH" "$TMP_STAGE_DIR/"
else
    echo "[!] bootstrap-clone.sh not found locally. Skipping."
fi

# SCP to VM
echo "Transferring bootstrap files to VM..."
sudo scp -r "$TMP_STAGE_DIR" "$VM_USER@$VM_IP:/tmp/"

# Cleanup local
echo "Cleaning up local temporary files..."
rm -rf "$TMP_STAGE_DIR"
rm -f "$PRIVATE_KEY_PATH" "$PUBLIC_KEY_PATH"

# Final local admin audit log
cat <<EOF > "$LOG_FILE"
========================================
[Admin: $(hostname -s)]
Generated bootstrap key: $KEY_NAME
Transferred to VM: $VM_IP
Deleted local bootstrap key after transfer
Timestamp: $(date)
========================================
EOF

# Confirmation
echo
echo "[✓] Bootstrap key $KEY_NAME created and transferred."
echo "[✓] Local temp files deleted."
echo "[✓] Audit log saved at $LOG_FILE"
echo

