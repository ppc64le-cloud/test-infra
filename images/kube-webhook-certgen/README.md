# Kube-WebHook-CertGen v1.6.3

Kube-WebHook-CertGen is a utility that automatically generates and manages TLS certificates for Kubernetes admission webhooks.

In the kube-prometheus-stack helm chart, it’s used to create and rotate certificates for components like the Prometheus Operator’s webhooks, ensuring secure communication between the API server and the webhook services.

## How to build

### Classic Docker build (on ppc64le environment)
```
$ docker build -t quay.io/powercloud/kube-webhook-certgen:v1.6.3 .
$ docker push quay.io/powercloud/kube-webhook-certgen:v1.6.3
```
### Docker Buildx
```
$ docker buildx build --platform=linux/ppc64le -t quay.io/powercloud/kube-webhook-certgen:v1.6.3 . --push
```