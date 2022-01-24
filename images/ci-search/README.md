# ci-search

> Reference: https://github.com/openshift/ci-search/blob/master/Dockerfile
This is an image used for bringing up openshift's ci-search tool for our internal Prow infra that runs jobs on ppc64le architecture, includes following content:

## How to build

```shell script
$ docker build -t quay.io/powercloud/ci-search:latest .

$ docker push quay.io/powercloud/ci-search:latest
```
> Note: This tool is tested only on x86 platform.
