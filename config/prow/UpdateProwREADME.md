# Update IKS Prow cluster with the latest community version

## Steps to be followed

#### 1: Pick up the latest prow version value from the commits
https://github.com/kubernetes/test-infra/commits/master/config/prow

#### 2: Update version here
https://github.com/ppc64le-cloud/test-infra/blob/master/images/pod-utilities/version.txt#L1

#### 3: Build and Push podutility images to quay.io
Wait for the postsubmit-podutilities-job to push images to quay repo.
Check the dashboard https://prow.ppc64le-cloud.cis.ibm.net/ for job completion.

#### 4: Check for spec changes
Keenly observe the commits/changes between your current prow version and the version to which you are upgrading. Make a note of changes to be added.
(https://github.com/kubernetes/test-infra/commits/master/config/prow)

#### 5: Update the spec files
If there are any changes observed in step 4, make them here  https://github.com/ppc64le-cloud/test-infra/tree/master/config/prow/cluster

#### 6: Update pod-utilities tag in config.yaml
https://github.com/ppc64le-cloud/test-infra/blob/master/config/prow/config.yaml#L69:L72

##### 7: Submit a PR to ppc64le-cloud/test-infra for incorporating spec changes
https://github.com/ppc64le-cloud/test-infra/tree/master/config/prow/cluster

#### 8: Apply changed specs in IKS prow cluster.
kubectl apply -f <component_deployment>.yaml

#### 9: Confirm the successful upgradation 
Check logs of prow-components on the cluster to see no failures.
Obeserving the prow dashboard https://prow.ppc64le-cloud.cis.ibm.net/ for job runs.
