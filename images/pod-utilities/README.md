# How to build


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
