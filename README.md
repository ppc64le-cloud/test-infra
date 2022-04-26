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

## Tools exposed via this repository

- https://prow.ppc64le-cloud.org/ - Dashboard for internal prow jobs that run on ppc64le build cluster and a few on IKS(x86) cluster.
- https://search.ppc64le-cloud.org/ - ci-search tool by openshift, configured to our internal prow jobs that have logs uploaded to GCS storage.
- https://jenkins.ppc64le-cloud.org/ - Jenkins dashboard for OCP jobs run on Jenkins infra.
- https://grafana.ppc64le-cloud.org - Grafana dashboard for analysing OCP jobs from Jenkins.
