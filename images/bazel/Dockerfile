ARG UBUNTU_VERSION=16.04
FROM ppc64le/ubuntu:${UBUNTU_VERSION}

ARG BAZEL_VERSION=2.2.0
ARG UBUNTU_VERSION

RUN apt-get update \
    && apt-get install -y default-jdk gcc git patch python python3 wget

RUN wget --no-verbose https://oplab9.parqtec.unicamp.br/pub/ppc64el/bazel/ubuntu_${UBUNTU_VERSION}/bazel_bin_ppc64le_${BAZEL_VERSION} \
    && mv bazel_bin_ppc64le_${BAZEL_VERSION} /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel
