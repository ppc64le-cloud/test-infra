##
# Build Dind image for docker-ce using locally built docker-ce packages instead of the one from the Debian's repo
# This is inspired from  https://github.com/alunsin/all_in_one_dind/blob/90d0d0df6de2ea4d0666f3e10adce28a5fffcc88/Dockerfile
##

FROM debian:bullseye

ARG CONTAINERD_VERSION=1.4.6-1
ENV CONTAINERD_VERSION ${CONTAINERD_VERSION:-1.4.6-1}

ARG DOCKER_VERSION=20.10.7~3-0
ENV DOCKER_VERSION ${DOCKER_VERSION:-20.10.7~3-0}

WORKDIR /workspace
RUN mkdir -p /workspace
ENV WORKSPACE=/workspace \
    TERM=xterm

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    gnupg2 \
    software-properties-common \
    lsb-release \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    make \
    openssh-client \
    pkg-config \
    procps \
    rsync \
    s3fs \
    unzip \
    wget \
    xz-utils \
    zip \
    zlib1g-dev \
    iptables libdevmapper1.02.1 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace/tmp

RUN set -eux; \
    \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        'amd64') \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/containerd.io_${CONTAINERD_VERSION}_amd64.deb -P /workspace/tmp; \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce-cli_$DOCKER_VERSION~debian-bullseye_amd64.deb -P /workspace/tmp; \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce_$DOCKER_VERSION~debian-bullseye_amd64.deb -P /workspace/tmp; \
            ;; \
        'ppc64el') \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/ppc64el/containerd.io_${CONTAINERD_VERSION}_ppc64el.deb -P /workspace/tmp; \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/ppc64el/docker-ce-cli_$DOCKER_VERSION~debian-bullseye_ppc64el.deb -P /workspace/tmp; \
            wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/ppc64el/docker-ce_$DOCKER_VERSION~debian-bullseye_ppc64el.deb -P /workspace/tmp; \
            ;; \
    esac; \
    \
    dpkg -i /workspace/tmp/*\
    && rm -rf /workspace/tmp; \
    rm -rf /var/lib/apt/lists/*

##
#Docker in Docker inspired from
#  https://github.com/docker-library/docker/tree/master/20.10/dind
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
##
RUN set -eux; \
        addgroup --system dockremap; \
        adduser --system --ingroup dockremap dockremap; \
        echo 'dockremap:165536:65536' >> /etc/subuid; \
        echo 'dockremap:165536:65536' >> /etc/subgid

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT ed89041433a031cafc0a0f19cfe573c31688d377

RUN set -eux; \
        wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
        chmod +x /usr/local/bin/dind;

#COPY dockerd-entrypoint.sh /usr/local/bin/
RUN set -eux; \
    wget https://raw.githubusercontent.com/docker-library/docker/094faa88f437cafef7aeb0cc36e75b59046cc4b9/20.10/dind/dockerd-entrypoint.sh;\
    chmod +x dockerd-entrypoint.sh;\
    mv dockerd-entrypoint.sh /usr/local/bin

VOLUME /var/lib/docker
EXPOSE 2375 2376

CMD ["dockerd-entrypoint.sh"]