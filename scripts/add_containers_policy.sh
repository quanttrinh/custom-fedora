#!/bin/bash
set -euo pipefail

# TO BE RUN AS ROOT!!

if [ "$EUID" -ne 0 ]; then
  echo "Please run $0 as root!" >&2
  exit 1
fi

mkdir -p /etc/containers/
jq '
. + {
  transports: (
    .transports + {
      "docker": (
        .transports["docker"] + {
          "ghcr.io/quanttrinh/fedora-kinoite": [
            {
              "type": "sigstoreSigned",
              "keyPath": "/etc/pki/containers/ghcr.io-quanttrinh-fedora-kinoite.pub",
              "signedIdentity": {
                "type": "matchRepository"
              }
            }
          ],
        }
      )
    }
  )
}
' /etc/containers/policy.json > /etc/containers/policy.json

mkdir -p /etc/containers/registries.d
cat <<EOF > /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml
docker:
    ghcr.io/quanttrinh/fedora-kinoite:
        use-sigstore-attachments: true
EOF
restorecon -RFv /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml