#!/bin/bash
set -euo pipefail

systemctl enable lactd
systemctl disable NetworkManager-wait-online.service
