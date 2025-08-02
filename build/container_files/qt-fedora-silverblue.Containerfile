ARG IMAGE
ARG TAG

FROM ${IMAGE}:${TAG}

COPY --from=system_files /silverblue /
COPY --from=scripts /shared /var/scripts/shared
COPY --from=scripts /silverblue /var/scripts/silverblue

RUN \
  set -xeuo pipefail; \
  /var/scripts/shared/add_containers_policy.sh silverblue; \
  /var/scripts/shared/ostree_commit.sh;
