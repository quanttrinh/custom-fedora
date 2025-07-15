#!/bin/bash
set -euo pipefail

# TO BE RUN AS ROOT!!

if [ "$EUID" -ne 0 ]; then
  echo "Please run $0 as root!" >&2
  exit 1
fi

KEY_FILE=""
INSTALL_PATH=""
for arg in "$@"; do
  case $arg in
  --key_file=*)
    KEY_FILE="${arg#*=}"
    ;;
  --install_path=*)
    INSTALL_PATH="${arg#*=}"
    ;;
  --help|-h)
    echo "Usage: $0 --key_file=<key_file> --install_path=<install_path>"
    echo "Where <key_file> is the path to the key file"
    echo "Where <install_path> is the path to folder where to install the key"
    exit 0
    ;;
  *)
    echo "Unknown option: $arg"
    exit 1
    ;;
  esac
done

FILE_NAME=${KEY_FILE##*/}

if [[ -z "$KEY_FILE" || -z "$INSTALL_PATH" || -z "$FILE_NAME" ]]; then
  echo "Usage: $0 --key_file=<key_file> --install_path=<install_path>" >&2
  echo "Where <key_file> is the path to the key file" >&2
  echo "Where <install_path> is the path to folder where to install the key" >&2
  exit 1
fi

echo "Supplied key file: ${KEY_FILE}"
echo "Installation path: ${INSTALL_PATH}/${FILE_NAME}"

mkdir -p "${INSTALL_PATH}"
cp "${KEY_FILE}" "${INSTALL_PATH}/${FILE_NAME}"

restorecon -RFv "${INSTALL_PATH}"
