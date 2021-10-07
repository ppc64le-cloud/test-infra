ARG POD_UTILITY=clonerefs
FROM golang:1.17 as builder

ARG POD_UTILITY
ARG CO_COMMIT=master

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/kubernetes/test-infra.git \
    && cd test-infra \
    && git checkout ${CO_COMMIT} \
    && CGO_ENABLED=0 go build -a -tags netgo -ldflags '-w -extldflags "-static"' -o /usr/local/bin/${POD_UTILITY} ./prow/cmd/${POD_UTILITY}

FROM alpine:latest
ARG POD_UTILITY
ENV EP_CMD=$POD_UTILITY
RUN apk add --no-cache git openssh ca-certificates && update-ca-certificates

COPY --from=builder /usr/local/bin/${POD_UTILITY} /${POD_UTILITY}

ENTRYPOINT /${EP_CMD}
