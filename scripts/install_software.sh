#!/bin/bash
set -euo pipefail

dnf install -y --best --allowerasing \
    libfprint-tod \
    distrobox \
    rclone \
    steam-devices \
    podman-compose \
    podman-docker \
    hardinfo2 \
    zsh \
    fira-code-fonts \
    lact
