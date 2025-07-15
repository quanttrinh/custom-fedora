#!/bin/bash
set -euo pipefail

CURRENT_KARGS=$(rpm-ostree kargs)
KARGS_ARGS=()
for keyval in "$@"
do
    for arg in $(echo "$CURRENT_KARGS" | grep -oP "(?<= |^)$keyval" )
    do  KARGS_ARGS+=("--delete-if-present=$arg")
    done
    KARGS_ARGS+=("--append-if-missing=$keyval")
done

rpm-ostree kargs "${KARGS_ARGS[@]}"
