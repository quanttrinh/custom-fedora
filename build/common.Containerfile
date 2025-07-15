ARG VARIANT
ARG IMAGE
ARG TAG

FROM ${IMAGE}:${TAG}

ARG VARIANT
ENV VARIANT=${VARIANT}

COPY --from=shared / /var/shared/
COPY --from=scripts / /var/scripts/

RUN \
  set -xeuo pipefail; \
  chmod a+x /var/scripts/*; \
  /var/scripts/add_containers_policy.sh "$VARIANT"; \
  /var/scripts/add_key.sh \
    --key_file=/var/shared/keys/pki/ghcr.io-quanttrinh-custom-fedora.pub \
    --install_path=/etc/pki/containers; \
  /var/scripts/setup_yum_repos.sh; \
  /var/scripts/install_software.sh; \
  /var/scripts/install_multimedia.sh; \
  /var/scripts/debloat.sh; \
  chsh -s /usr/bin/zsh; \
  /var/scripts/ostree_commit.sh
