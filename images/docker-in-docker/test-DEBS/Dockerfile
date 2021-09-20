# Dockerfile to test DEBS packages

ARG GOLANG_VERSION=1.15.2
ARG DISTRO_NAME
ARG DISTRO_VERS

FROM ppc64le/$DISTRO_NAME:$DISTRO_VERS

ARG GOLANG_VERSION
ARG DISTRO_NAME
ARG DISTRO_VERS
ARG DOCKER_VERS
ARG CONTAINERD_VERS

WORKDIR /workspace
RUN mkdir -p /workspace
ENV WORKSPACE=/workspace \
    TERM=xterm
ENV PATH /usr/local/go/bin:$PATH


RUN echo deb;\
    apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    wget \
    software-properties-common \
    lsb-release\
    ##### Install go tests deps
    make\
    gcc\
    libc-dev\
    procps\
    ##### Install docker-ce deps
    iptables libdevmapper1.02.1 && \
    rm -rf /var/lib/apt/lists/* 

COPY bundles-*.tar.gz /workspace/
COPY *.deb /workspace/
COPY test_launch.sh /usr/local/bin

RUN set -eux; \
        tar -xvzf bundles-*.tar.gz --wildcards  --strip-components 4 '*.deb' &&\
        dpkg -i *.deb

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

RUN set -eux; \
	url="https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-ppc64le.tar.gz";\
    wget -O go.tgz "$url" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    go version;

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["test_launch.sh"]
CMD []
