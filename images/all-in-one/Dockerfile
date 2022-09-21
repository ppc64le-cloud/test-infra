ARG GOLANG_VERSION=1.18.6
ARG IBM_CLOUD_VERSION=2.10.0
ARG TERRAFORM_PROVIDER_IBM_VERSION=1.39.1
ARG TERRAFORM_PROVIDER_NULL_VERSION=3.1.0
FROM golang:$GOLANG_VERSION AS builder

RUN go install rsc.io/goversion@v1.2.0 \
    && GO111MODULE=on

ARG TF_VERSION
ENV TF_VERSION ${TF_VERSION:-v1.1.7}

ARG TERRAFORM_PROVIDER_IBM_VERSION
ENV TERRAFORM_PROVIDER_IBM_VERSION=$TERRAFORM_PROVIDER_IBM_VERSION

ARG TERRAFORM_PROVIDER_NULL_VERSION
ENV TERRAFORM_PROVIDER_NULL_VERSION=$TERRAFORM_PROVIDER_NULL_VERSION

WORKDIR /workspace

RUN git clone -b $TF_VERSION --single-branch https://github.com/hashicorp/terraform.git && \
    cd terraform && \
    go install .

RUN git clone -b v${TERRAFORM_PROVIDER_IBM_VERSION} --single-branch https://github.com/IBM-Cloud/terraform-provider-ibm && \
    cd terraform-provider-ibm && \
    go build .

RUN git clone -b v${TERRAFORM_PROVIDER_NULL_VERSION} --single-branch https://github.com/hashicorp/terraform-provider-null && \
    cd terraform-provider-null && \
    go build .

FROM debian:bullseye

ARG TF_PLUGIN_PATH
ENV TF_PLUGIN_PATH ${TF_PLUGIN_PATH:-/root/.terraform.d/plugins/registry.terraform.io/hashicorp}

ARG GOLANG_VERSION
ENV GOLANG_VERSION ${GOLANG_VERSION:-1.18.6}

ARG IBM_CLOUD_VERSION
ENV IBM_CLOUD_VERSION ${IBM_CLOUD_VERSION:-2.10.0}

WORKDIR /workspace
RUN mkdir -p /workspace
ENV WORKSPACE=/workspace \
    TERM=xterm
ENV PATH /usr/local/go/bin:$PATH

ARG KUBECTL_VERSION=v1.24.4

COPY --from=builder /go/bin/* /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    lsb-release && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
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
            ibm_cloud_url="https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBM_CLOUD_VERSION}/IBM_Cloud_CLI_${IBM_CLOUD_VERSION}_amd64.tar.gz"; \
            ;; \
        'ppc64el') \
            url="https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-ppc64le.tar.gz"; \
            ibm_cloud_url="https://download.clis.cloud.ibm.com/ibm-cloud-cli/${IBM_CLOUD_VERSION}/IBM_Cloud_CLI_${IBM_CLOUD_VERSION}_ppc64le.tar.gz"; \
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
    rm -rf /var/lib/apt/lists/*; \
    curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/`go env GOARCH`/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

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

ARG TERRAFORM_PROVIDER_IBM_VERSION
ENV TERRAFORM_PROVIDER_IBM_VERSION=$TERRAFORM_PROVIDER_IBM_VERSION

ARG TERRAFORM_PROVIDER_NULL_VERSION
ENV TERRAFORM_PROVIDER_NULL_VERSION=$TERRAFORM_PROVIDER_NULL_VERSION

COPY --from=builder /workspace/terraform-provider-ibm/terraform-provider-ibm /tmp/
COPY --from=builder /workspace/terraform-provider-null/terraform-provider-null /tmp/

RUN mkdir -p ${TF_PLUGIN_PATH}/ibm/${TERRAFORM_PROVIDER_IBM_VERSION}/linux_`go env GOARCH` && \
    cp /tmp/terraform-provider-ibm ${TF_PLUGIN_PATH}/ibm/${TERRAFORM_PROVIDER_IBM_VERSION}/linux_`go env GOARCH` && \
    mkdir -p ${TF_PLUGIN_PATH}/null/${TERRAFORM_PROVIDER_NULL_VERSION}/linux_`go env GOARCH` && \
    cp /tmp/terraform-provider-null ${TF_PLUGIN_PATH}/null/${TERRAFORM_PROVIDER_NULL_VERSION}/linux_`go env GOARCH`
