#!/bin/bash
set -euo pipefail

sed -i -r 's|(SHELL=).*($)|\1/bin/zsh\2|g' /etc/default/useradd

chsh -s /bin/zsh
