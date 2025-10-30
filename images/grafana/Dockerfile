# Build stage
FROM golang:1.24.4 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl build-essential ca-certificates python3 python3-pip \
    chromium chromium-driver && \
    rm -rf /var/lib/apt/lists/*

ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22.16.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV NODE_OPTIONS=--max_old_space_size=12000

RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /src

COPY 0001-patch-swc-loader-to-babel-for-ppc64le.patch /tmp/

RUN git clone https://github.com/grafana/grafana.git . && \
    git checkout v12.1.0 && \
    git apply /tmp/0001-patch-swc-loader-to-babel-for-ppc64le.patch && \
    make deps-go  && \
    make deps  && \
    yarn add --dev babel-loader @babel/core @babel/preset-env @babel/preset-typescript @babel/preset-react && \
    make build

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tini && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -u 472 -r -g 0 -d /usr/share/grafana -s /sbin/nologin grafana

WORKDIR /usr/share/grafana

COPY --from=builder /src/bin/linux-ppc64le/grafana ./bin/
COPY --from=builder /src/conf ./conf
COPY --from=builder /src/public ./public

ENV PATH=/usr/share/grafana/bin:$PATH

RUN chown -R grafana:root /usr/share/grafana && chmod -R g+rwX /usr/share/grafana

USER grafana

EXPOSE 3000

ENTRYPOINT ["/usr/share/grafana/bin/grafana"]
CMD ["server", "--homepath=/usr/share/grafana"]
