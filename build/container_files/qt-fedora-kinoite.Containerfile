ARG IMAGE
ARG TAG

FROM ${IMAGE}:${TAG}

COPY --from=system_files /kinoite /
COPY --from=scripts /shared /var/scripts/shared
COPY --from=scripts /kinoite /var/scripts/kinoite

RUN \
  set -xeuo pipefail; \
  /var/scripts/shared/add_containers_policy.sh kinoite; \
  /var/scripts/kinoite/setup_services.sh; \
  /var/scripts/shared/ostree_commit.sh;
