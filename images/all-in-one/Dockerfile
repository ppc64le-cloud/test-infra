ARG GOLANG_VERSION=1.15.2
ARG BAZEL_VERSION=2.2.0
ARG IBM_CLOUD_VERSION=1.2.1
FROM golang:$GOLANG_VERSION AS builder

ARG TF_VERSION
ENV TF_VERSION ${TF_VERSION:-v0.13.6}

RUN go get rsc.io/goversion \
    && GO111MODULE=on

FROM debian:buster

ARG TERRAFORM_PROVIDER_IBM_VERSION
ENV TERRAFORM_PROVIDER_IBM_VERSION ${TERRAFORM_PROVIDER_IBM_VERSION:-1.21.2}

ARG TERRAFORM_PROVIDER_NULL_VERSION
ENV TERRAFORM_PROVIDER_NULL_VERSION ${TERRAFORM_PROVIDER_NULL_VERSION:-2.1.2}

ARG TF_PLUGIN_PATH
ENV TF_PLUGIN_PATH ${TF_PLUGIN_PATH:-/root/.terraform/plugins/registry.terraform.io/hashicorp}

ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.15.2}

ARG BAZEL_VERSION
ENV BAZEL_VERSION ${BAZEL_VERSION:-2.2.0}

ARG IBM_CLOUD_VERSION
ENV IBM_CLOUD_VERSION ${IBM_CLOUD_VERSION:-1.2.1}

WORKDIR /workspace
RUN mkdir -p /workspace
ENV WORKSPACE=/workspace \
    TERM=xterm
ENV PATH /usr/local/go/bin:$PATH

COPY --from=builder /go/bin/* /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    lsb-release && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
    && apt-get update && apt-get install -y --no-install-recommends \
    ansible \
    build-essential \
    ca-certificates \
    curl \
    default-jdk \
    file \
    git \
    gcc \
    jq \
    make \
    mercurial \
    openssh-client \
    pkg-config \
    procps \
    python \
    python-dev \
    python-gflags \
    python-openssl \
    python-pip \
    python-yaml \
    python3 \
    python3-distutils \
    python3-gflags \
    python3-pip \
    python3-yaml \
    rsync \
    unzip \
    wget \
    xz-utils \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        'amd64') \
            url="https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
            ibm_cloud_url="https://clis.ng.bluemix.net/download/bluemix-cli/${IBM_CLOUD_VERSION}/linux64"; \
            curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg; \
            mv bazel.gpg /etc/apt/trusted.gpg.d/; \
            echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list; \
            apt update && apt install -y bazel=$BAZEL_VERSION; \
            ;; \
        'ppc64el') \
            url="https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-ppc64le.tar.gz"; \
            ibm_cloud_url="https://clis.ng.bluemix.net/download/bluemix-cli/${IBM_CLOUD_VERSION}/ppc64le"; \
            wget -O /usr/local/bin/bazel "https://oplab9.parqtec.unicamp.br/pub/ppc64el/bazel/ubuntu_18.04/bazel_bin_ppc64le_$BAZEL_VERSION" --progress=dot:giga; \
            chmod +x /usr/local/bin/bazel; \
            ;; \
        's390x') \
            url="https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-s390x.tar.gzr"; \
            ;; \
    esac; \
    \
    wget -O go.tgz "$url" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz; \
    go version; \
    wget -O ibm_cloud.tgz "$ibm_cloud_url" --progress=dot:giga; \
    tar -xf ibm_cloud.tgz; \
    ./Bluemix_CLI/install; \
    ibmcloud plugin install power-iaas; \
    ibmcloud plugin install cloud-object-storage; \
    rm -rf ./Bluemix_CLI; \
    rm ibm_cloud.tgz; \
    rm -rf /var/lib/apt/lists/*

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ENV PATH=/google-cloud-sdk/bin:/workspace:${PATH} \
    CLOUDSDK_CORE_DISABLE_PROMPTS=1

RUN wget -q https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz && \
    tar xzf google-cloud-sdk.tar.gz -C / && \
    rm google-cloud-sdk.tar.gz && \
    gcloud components install alpha beta gsutil && \
    gcloud info | tee /workspace/gcloud-info.txt

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/`go env GOARCH`/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN git clone -b 'v0.13.6' --single-branch https://github.com/hashicorp/terraform.git && \
    cd terraform && \
    go install .

RUN git clone -b 'v1.21.2' --single-branch https://github.com/IBM-Cloud/terraform-provider-ibm && \
         cd terraform-provider-ibm && \
         go build .

RUN git clone -b 'v2.1.2' --single-branch https://github.com/hashicorp/terraform-provider-null && \
	cd terraform-provider-null && \
	go build . 

RUN mkdir -p ${TF_PLUGIN_PATH}/ibm/${TERRAFORM_PROVIDER_IBM_VERSION}/linux_`go env GOARCH`
RUN mkdir -p ${TF_PLUGIN_PATH}/null/${TERRAFORM_PROVIDER_NULL_VERSION}/linux_`go env GOARCH`
RUN mv /workspace/terraform-provider-ibm/terraform-provider-ibm ${TF_PLUGIN_PATH}/ibm/${TERRAFORM_PROVIDER_IBM_VERSION}/linux_`go env GOARCH`
RUN mv /workspace/terraform-provider-null/terraform-provider-null ${TF_PLUGIN_PATH}/null/${TERRAFORM_PROVIDER_NULL_VERSION}/linux_`go env GOARCH`
