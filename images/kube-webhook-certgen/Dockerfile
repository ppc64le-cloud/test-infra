#Builder stage
FROM golang:1.25 AS builder

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/kubernetes/ingress-nginx.git /ingress-nginx && \
    cd /ingress-nginx && \
    git checkout controller-v1.13.3 
#This specific release contains kube-webhook-certgen v1.6.3

WORKDIR /ingress-nginx/images/kube-webhook-certgen/rootfs

RUN go mod tidy && \
    CGO_ENABLED=0 go build -a -o kube-webhook-certgen main.go

#Runtime stage
FROM gcr.io/distroless/static:nonroot

WORKDIR /
COPY --from=builder /ingress-nginx/images/kube-webhook-certgen/rootfs/kube-webhook-certgen /kube-webhook-certgen

USER 65532:65532

ENTRYPOINT ["/kube-webhook-certgen"]
