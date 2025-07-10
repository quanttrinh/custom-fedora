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
' /etc/containers/policy.json | tee /etc/containers/policy.json
echo $(cat /etc/containers/policy.json)

mkdir -p /etc/containers/registries.d
echo \
'
docker:
    ghcr.io/quanttrinh/fedora-kinoite:
        use-sigstore-attachments: true
' | tee /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml
restorecon -RFv /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml