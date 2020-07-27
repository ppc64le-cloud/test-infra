# test-infra

## How to test the ProwJob

#### Method 1: Test using the kind cluster
https://github.com/kubernetes/test-infra/blob/master/prow/build_test_update.md#using-pj-on-kindsh

#### Method 2: Test on the already deployed kubernetes cluster

```shell script
# set the kubeconfig to proper cluster
$ export KUBECONFIG=/home/.kube/config

# run the ./hack/test-pj.sh script, following the script runs the k8s-ppc64le-cluster-health-check on the cluster configured by KUBECONFIG(default: ${HOME}/.kube/config)
$ CONFIG_PATH=$(pwd)/config/prow/config.yaml JOB_CONFIG_PATH=$(pwd)/config/jobs/ppc64le-cloud/test-infra/test-infra-periodics.yaml ./hack/test-pj.sh k8s-ppc64le-cluster-health-check
```
