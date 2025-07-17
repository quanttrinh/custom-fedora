#!/bin/bash
set -euo pipefail

dnf clean all
rm -rf /var/*
bootc container lint
ostree container commit
