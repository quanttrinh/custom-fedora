#!/bin/bash
set -euo pipefail

dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf swap -y $(rpm -q rpmfusion-free-release) rpmfusion-free-release
dnf swap -y $(rpm -q rpmfusion-nonfree-release) rpmfusion-nonfree-release
dnf install -y rpmfusion-nonfree-release-tainted

dnf copr enable -y quantt/libfprint-tod
dnf copr enable -y ilyaz/LACT

sed -i 's/enabled=1/enabled=0/' \
  /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo \
  /etc/yum.repos.d/google-chrome.repo \
  /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo

dnf clean all
dnf update -y --refresh
