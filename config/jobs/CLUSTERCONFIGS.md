# These are the config details of the k8s clusters deployed on powervs by the conformance prow jobs.

| Cluster Name        | Job that created                                             | K8S_BUILD_VERSION                                                  | runtime    |
|---------------------|--------------------------------------------------------------|--------------------------------------------------------------------|------------|
| config1-\<Timestamp\> | periodic-kubernetes-containerd-conformance-test-ppc64le      | latest nightly build from upstream                                 | containerd |
| config2-\<Timestamp\> | postsubmit-master-golang-kubernetes-conformance-test-ppc64le | k8s built by job postsubmit-kubernetes-build-golang-master-ppc64le | containerd     |

