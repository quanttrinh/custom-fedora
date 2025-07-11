#!/bin/bash
set -euo pipefail

# TO BE RUN AS ROOT!!

if [ "$EUID" -ne 0 ]; then
  echo "Please run $0 as root!" >&2
  exit 1
fi

VARIANT=$1
if [[ "$VARIANT" != "fedora-kinoite" && "$VARIANT" != "fedora-silverblue" ]]; then
  echo "Usage: $0 <variant>" >&2
  echo "Where <variant> is either 'fedora-kinoite' or 'fedora-silverblue'" >&2
  exit 1
fi
echo "Selected variant: $VARIANT"

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
jq --arg variant "ghcr.io/quanttrinh/$VARIANT" '
. + {
  transports: (
    (.transports // {}) + {
      "docker": (
        (.transports["docker"] // {}) + {
          ($variant): [
            {
              "type": "sigstoreSigned",
              "keyPath": "/etc/pki/containers/ghcr.io-quanttrinh-custom-fedora.pub",
              "signedIdentity": {
                "type": "matchRepository"
              }
            }
          ]
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
cat <<EOF > /etc/containers/registries.d/ghcr.io-quanttrinh.yaml
docker:
    ghcr.io/quanttrinh:
        use-sigstore-attachments: true
EOF
restorecon -RFv /etc/containers/registries.d/ghcr.io-quanttrinh.yaml
