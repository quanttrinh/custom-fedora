#!/bin/bash
set -euo pipefail

dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vulkan-drivers mesa-vulkan-drivers-freeworld

dnf install -y --best --allowerasing \
  --exclude=gstreamer1-*-devel \
  --exclude=lame-devel \
  openh264 \
  mozilla-openh264 \
  ffmpeg \
  ffmpeg-libs \
  libva \
  libva-utils \
  libavcodec-freeworld \
  pipewire-codec-aptx \
  ffmpegthumbnailer \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-good \
  gstreamer1-plugins-ugly \
  gstreamer1-plugin-openh264 \
  gstreamer1-libav \
  gstreamer1-vaapi \
  gstreamer1-svt-hevc \
  lame*
dnf group install -y --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --exclude=vlc-plugins-freeworld multimedia
