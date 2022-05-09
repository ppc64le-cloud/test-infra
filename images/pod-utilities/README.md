## Deprecated
03 May 2022 - Usage of pod-utility images from locally built and pushed `quay.io/powercloud` private repo is deprecated.


The upstream pod-utility images from `gcr.io/k8s-prow` will be used - [Change](https://github.com/ppc64le-cloud/test-infra/pull/309/files#diff-d840b3456d7d17beb3ded91cf0ca9d6fd065baedb31a0a634b5101df3f7925d4L77)

### How to build


```shell
# Pull amd64 images and push them to private repos
$ make all-pull
$ make all-tag
$ make all-push

# Build and Push images for ppc64le platform
$ make all-build
$ ARCH=ppc64le make all-push

# Push docker manifest
$ make all-push-manifest
```
