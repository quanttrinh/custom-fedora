#!/bin/bash
set -euo pipefail

# TO BE RUN AS ROOT!!

if [ "$EUID" -ne 0 ]; then
  echo "Please run $0 as root!" >&2
  exit 1
fi

VARIANT=$1
if [[ "$VARIANT" != "kinoite" && "$VARIANT" != "silverblue" ]]; then
  echo "Usage: $0 <variant>" >&2
  echo "Where <variant> is either 'kinoite' or 'silverblue'" >&2
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

cat /etc/containers/policy.json

restorecon -RFv /etc/containers
