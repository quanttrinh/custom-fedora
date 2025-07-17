#!/bin/bash
set -euo pipefail

dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
dnf swap -y mesa-vulkan-drivers mesa-vulkan-drivers-freeworld

dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
dnf swap -y mesa-vulkan-drivers.i686 mesa-vulkan-drivers-freeworld.i686

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
  gstreamer1-plugins-bad-free-extras \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-good-extras \
  gstreamer1-plugins-good-gtk \
  gstreamer1-plugins-ugly \
  gstreamer1-plugin-openh264 \
  gstreamer1-libav \
  gstreamer1-vaapi \
  gstreamer1-svt-hevc \
  lame*
dnf group install -y --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --exclude=vlc-plugins-freeworld multimedia
