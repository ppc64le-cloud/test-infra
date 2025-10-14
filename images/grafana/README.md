# Grafana v12.1.0

## How to build

### Classic Docker build 
```
$ docker build -t quay.io/powercloud/grafana:v12.1.0 .

$ docker push quay.io/powercloud/grafana:v12.1.0
```
### Docker Buildx
```
$ docker buildx build \
  --platform linux/ppc64le \
  -t quay.io/powercloud/grafana:v12.1.0 \
  --push .

```

## Issues addressed for Grafana v12.1.0 

#### 1. Image cannot be built with newer versions of node - https://github.com/grafana/grafana/issues/109218
>     Fixed by using specific node version mentioned in grafana/.nvmrc (v22.16.0)

#### 2. swc loader is not available for ppc64le
>     Replaced with babel (compiler). These changes are contained in the patch "0001-patch-swc-loader-to-babel-for-ppc64le.patch"
>     This will be applied after git checkout.

#### 3. High disk space and memory requirement for image build
>     Image build will often fail due to disk space and memory crunch.  
>     Ensure the nodes running the docker daemon have plenty of memory and disk space. 
>     12 GiB of Memory is enforced within Dockerfile using "ENV NODE_OPTIONS=--max_old_space_size=12000"


