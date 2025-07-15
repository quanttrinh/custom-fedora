#!/bin/bash
set -euo pipefail

# Relaunch with root if not already
if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

# Parse arguments
KARGS=""
for arg in "$@"; do
  case $arg in 
  --variant=*)
    VARIANT="${arg#*=}"
    ;;
  --extra-kargs=*)
    RAW_KARGS="${arg#*=}"
    KARGS=${RAW_KARGS//,/ }
    ;;
  --help|-h)
    echo "Usage: $0 --variant=<variant> --extra-kargs=<kargs>"
    echo "Where <variant> is either 'kinoite' or 'silverblue'"
    echo "Where <kargs> is extra kernel parameters to be added"
    exit 0
    ;;
  *)
    echo "Unknown option: $arg"
    exit 1
    ;;
  esac
done

if [[ "$VARIANT" != "kinoite" && "$VARIANT" != "silverblue" ]]; then
  echo "Usage: $0 --variant=<variant> --extra-kargs=<kargs>" >&2
  echo "Where <variant> is either 'kinoite' or 'silverblue'" >&2
  echo "Where <kargs> is extra kernel parameters to be added" >&2
  exit 1
fi

echo "Selected variant: $VARIANT"
echo "Extra kargs: $KARGS"

# Download container policy public key
echo "Downloading public key..."
wget -q "https://raw.githubusercontent.com/quanttrinh/custom-fedora/main/shared/pki/ghcr.io-quanttrinh-custom-fedora.pub" \
     -O /etc/pki/containers/ghcr.io-quanttrinh-custom-fedora.pub

# Check and download policy script
FILE="scripts/add_containers_policy.sh"
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist, downloading..."
    wget -q "https://raw.githubusercontent.com/quanttrinh/custom-fedora/main/scripts/add_containers_policy.sh" -O "$FILE"
    chmod +x "$FILE"
fi

# Execute the policy script
echo "Applying container policy..."
./"$FILE" "$VARIANT"

# Restore SELinux context
echo "Restoring SELinux context..."
restorecon -RFv /etc/containers
restorecon -RFv /etc/pki

# Rebase to the new image
echo "Rebasing to new image..."
rpm-ostree rebase ostree-image-signed:registry:ghcr.io/quanttrinh/$VARIANT:latest

# Check and download kargs setup helper script
if [[ -n "${KARGS//[[:space:]]/}" ]]; then
  FILE="scripts/setup_kargs_helper.sh"
  if [ ! -f "$FILE" ]; then
      echo "$FILE does not exist, downloading..."
      wget -q "https://raw.githubusercontent.com/quanttrinh/custom-fedora/main/scripts/setup_kargs_helper.sh" -O "$FILE"
      chmod +x "$FILE"
  fi
  ./"$FILE" $KARGS
fi
