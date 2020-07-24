ARG POD_UTILITY=clonerefs
FROM ppc64le/ubuntu:18.04 as builder

ARG UBUNTU_VERSION=18.04
ARG BAZEL_VERSION=3.1.0
ARG DEBIAN_FRONTEND=noninteractive
ARG POD_UTILITY
ARG CO_COMMIT=master

COPY nodejs.patch /tmp

RUN apt-get update && apt-get install -y \
    default-jdk \
    g++ \
    git \
    python \
    python3 \
    python3-dev \
    wget

RUN wget --no-verbose https://oplab9.parqtec.unicamp.br/pub/ppc64el/bazel/ubuntu_${UBUNTU_VERSION}/bazel_bin_ppc64le_${BAZEL_VERSION} \
    && mv bazel_bin_ppc64le_${BAZEL_VERSION} /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel

RUN git clone https://github.com/kubernetes/test-infra.git \
    && cd test-infra \
    && git checkout ${CO_COMMIT} \
    && patch -p1 < /tmp/nodejs.patch \
    && bazel build //prow/cmd/${POD_UTILITY} \
    && cp bazel-bin/prow/cmd/${POD_UTILITY}/linux_ppc64le_pure_stripped/${POD_UTILITY} /usr/local/bin/${POD_UTILITY}

FROM alpine:latest
ARG POD_UTILITY
ENV EP_CMD=$POD_UTILITY
RUN apk add --no-cache git openssh ca-certificates && update-ca-certificates

COPY --from=builder /usr/local/bin/${POD_UTILITY} /${POD_UTILITY}

ENTRYPOINT /${EP_CMD}
