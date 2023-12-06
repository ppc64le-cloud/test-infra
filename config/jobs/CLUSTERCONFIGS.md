# These are the config details of the k8s clusters deployed on powervs by the conformance prow jobs.

| Cluster Name        | Job that created                                             | K8S_BUILD_VERSION                                                  | runtime    | Purpose of Job        |
|---------------------|--------------------------------------------------------------|--------------------------------------------------------------------|------------|--------------------------|
| config1-\<Timestamp\> | periodic-kubernetes-containerd-conformance-test-ppc64le      | latest nightly build from upstream                                 | containerd | To run conformance tests from e2e suite        |
| config2-\<Timestamp\> | postsubmit-master-golang-kubernetes-conformance-test-ppc64le | k8s built by job postsubmit-kubernetes-build-golang-master-ppc64le | containerd     | To run conformance tests from e2e suite         |
| config3-\<Timestamp\> | periodic-kubernetes-containerd-e2e-node-tests-ppc64le | latest nightly build from upstream | containerd | To run NodeConformace tests from e2e-node suite |
