# test-infra

## How to test the ProwJob

#### Method 1: Test using the kind cluster
https://docs.prow.k8s.io/docs/build-test-update/#using-pj-on-kindsh

#### Method 2: Test on the already deployed kubernetes cluster

```shell script
# set the kubeconfig to proper cluster
$ export KUBECONFIG=/home/.kube/config

# run the ./hack/test-pj.sh script, following the script runs the k8s-ppc64le-cluster-health-check
# on the cluster configured by KUBECONFIG(default: ${HOME}/.kube/config) and creates 
# a file pod_table.txt in the present working directory with details about the 
# job. The -j flag is used to specify the job to be run and is mandatory. The -p (purpose) flag
# is used to specify the purpose for which the job is being run and is optional. 
# The job name and the purpose among other details will be populated in pod_table.txt 
# if the purpose flag is set.
$ CONFIG_PATH=$(pwd)/config/prow/config.yaml JOB_CONFIG_PATH=$(pwd)/config/jobs/ppc64le-cloud/test-infra/test-infra-periodics.yaml ./hack/test-pj.sh -j k8s-ppc64le-cluster-health-check -p "Cluster health after new jobs"
```

## Tools exposed via this repository

- https://prow.ppc64le-cloud.cis.ibm.net/ - Dashboard for internal prow jobs that run on ppc64le build cluster and a few on IKS(x86) cluster.
- https://search.ppc64le-cloud.cis.ibm.net/ - ci-search tool by openshift, configured to our internal prow jobs that have logs uploaded to GCS bucket ppc64le-kubernetes.
- https://k8ssearch.ppc64le-cloud.cis.ibm.net/ - ci-search tool by openshift, configured to upstream k8s prow jobs that have logs uploaded to GCS bucket kubernetes-ci-logs.
- https://jenkins.ppc64le-cloud.cis.ibm.net/ - Jenkins dashboard for OCP jobs run on Jenkins infra.
- https://grafana.ppc64le-cloud.cis.ibm.net - Grafana dashboard for analysing OCP jobs from Jenkins.

## Deprecated

03 May 2022 - Usage of pod-utility images from locally built and pushed `quay.io/powercloud` private repo is deprecated.

The upstream pod-utility images from `us-docker.pkg.dev/k8s-infra-prow/images` will be used.

[Change1](https://github.com/ppc64le-cloud/test-infra/pull/309/files#diff-d840b3456d7d17beb3ded91cf0ca9d6fd065baedb31a0a634b5101df3f7925d4L77) - Started using google container registry upstream images

[Change2](https://github.com/ppc64le-cloud/test-infra/pull/487/files#diff-d840b3456d7d17beb3ded91cf0ca9d6fd065baedb31a0a634b5101df3f7925d4R83) - Moved from using Container Registry to Temporary Upstream Artifact Registry. (May change to registry.k8s.io in future. Ref: [issue](https://github.com/kubernetes-sigs/prow/issues/113)

Files from [here](https://github.com/ppc64le-cloud/test-infra/tree/master/images/pod-utilities) will not be used.
