#!/bin/bash
set -euo pipefail

# Relaunch with root if not already
if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

# Download container policy public key
echo "Downloading public key..."
wget -q "https://raw.githubusercontent.com/quanttrinh/custom-fedora/main/shared/keys/ghcr.io-quanttrinh-fedora-kinoite.pub" \
     -O /etc/pki/containers/ghcr.io-quanttrinh-fedora-kinoite.pub

# Restore SELinux context
echo "Restoring SELinux context..."
restorecon -RFv /etc/pki/containers

# Check and download policy script
FILE="add_containers_policy.sh"
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist, downloading..."
    wget -q "https://raw.githubusercontent.com/quanttrinh/custom-fedora/main/scripts/add_containers_policy.sh" -O "$FILE"
    chmod +x "$FILE"
fi

# Execute the policy script
echo "Applying container policy..."
./"$FILE"

# Rebase to the new image
echo "Rebasing to new image..."
rpm-ostree rebase ostree-image-signed:registry:ghcr.io/quanttrinh/fedora-kinoite:latest
