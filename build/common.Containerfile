ARG VARIANT
ARG IMAGE
ARG TAG

FROM ${IMAGE}:${TAG}

ARG VARIANT
ENV VARIANT=${VARIANT}

COPY --from=shared / /var/shared/
COPY --from=scripts / /var/scripts/

RUN <<EORUN
set -xeuo pipefail

chmod a+x /var/scripts/add_containers_policy.sh
/var/scripts/add_containers_policy.sh "$VARIANT"

mkdir -p /etc/pki/containers
cp /var/shared/keys/pki/ghcr.io-quanttrinh-custom-fedora.pub /etc/pki/containers/ghcr.io-quanttrinh-custom-fedora.pub

restorecon -RFv /etc/pki
restorecon -RFv /etc/containers

cat /etc/containers/policy.json
cat /etc/containers/registries.d/ghcr.io-quanttrinh.yaml

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

dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
dnf swap -y mesa-vulkan-drivers mesa-vulkan-drivers-freeworld

dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
dnf swap -y mesa-vulkan-drivers.i686 mesa-vulkan-drivers-freeworld.i686

dnf install -y --best --allowerasing --exclude=gstreamer1-*-devel \
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
gstreamer1-svt-hevc
dnf install -y lame* --exclude=lame-devel
dnf group install -y --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --exclude=vlc-plugins-freeworld multimedia

systemctl disable NetworkManager-wait-online.service
systemctl enable lactd

chsh -s /usr/bin/zsh

dnf remove -y firefox*

dnf clean all
rm -rf /var/*
bootc container lint
ostree container commit
EORUN
