ARG IMAGE
ARG TAG

FROM ${IMAGE}:${TAG}

COPY --from=system_files /common/* /
COPY --from=scripts /shared /var/scripts/shared
COPY --from=scripts /common /var/scripts/common

RUN \
  set -xeuo pipefail; \
  /var/scripts/common/setup_yum_repos.sh; \
  /var/scripts/common/install_software.sh; \
  /var/scripts/common/install_multimedia.sh; \
  /var/scripts/common/debloat.sh; \
  /var/scripts/shared/ostree_commit.sh;
