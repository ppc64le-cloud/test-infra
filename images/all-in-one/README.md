# all-in-one

This is an image which contains following content:

- ibmcloud command and pi, cos plugins
- terraform
- ansible
- bazel
- go
- gcloud, gsutil
- jq 

## How to build

```shell script
# On both x86 and ppc64le platforms.
$ docker build -t quay.io/powercloud/all-in-one:`cat version.txt`-`uname -p | sed 's/x86_64/amd64/'` .

$ docker push quay.io/powercloud/all-in-one:`cat version.txt`-`uname -p | sed 's/x86_64/amd64/'`

# Push manifest
$ export DOCKER_CLI_EXPERIMENTAL=enabled

$ docker manifest create --amend quay.io/powercloud/all-in-one:`cat version.txt` quay.io/powercloud/all-in-one:`cat version.txt`-ppc64le quay.io/powercloud/all-in-one:`cat version.txt`-amd64
$ docker manifest annotate --arch ppc64le quay.io/powercloud/all-in-one:`cat version.txt` quay.io/powercloud/all-in-one:`cat version.txt`-ppc64le
$ docker manifest annotate --arch amd64 quay.io/powercloud/all-in-one:`cat version.txt` quay.io/powercloud/all-in-one:`cat version.txt`-amd64
$ docker manifest push quay.io/powercloud/all-in-one:`cat version.txt`
```
