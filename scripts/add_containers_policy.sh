#!/bin/bash
set -euo pipefail

# TO BE RUN AS ROOT!!

if [ "$EUID" -ne 0 ]; then
  echo "Please run $0 as root!" >&2
  exit 1
fi

POLICY_FILE=/etc/containers/policy.json
mkdir -p /etc/containers/
if [ ! -s "$POLICY_FILE" ]; then
    echo "$POLICY_FILE does not exist, generating default..."
    cat <<EOF > "$POLICY_FILE"
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker-daemon": {
      "": [{"type":"insecureAcceptAnything"}]
    }
  }
}
EOF
fi
jq '
. + {
  transports: (
    (.transports // {}) + {
      "docker": (
        (.transports["docker"] // {}) + {
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
' "$POLICY_FILE" > "$POLICY_FILE-tmp"
mv "$POLICY_FILE-tmp" "$POLICY_FILE"
jq '
. + {
  default: (
    ((.default // []) | map(select(. != { "type": "insecureAcceptAnything" }))) + [{ "type": "reject" }]
  )
}
' "$POLICY_FILE" > "$POLICY_FILE-tmp"
mv "$POLICY_FILE-tmp" "$POLICY_FILE"

mkdir -p /etc/containers/registries.d
cat <<EOF > /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml
docker:
    ghcr.io/quanttrinh/fedora-kinoite:
        use-sigstore-attachments: true
EOF
restorecon -RFv /etc/containers/registries.d/ghcr.io-quanttrinh-fedora-kinoite.yaml