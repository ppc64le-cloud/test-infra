# k8s-prow cluster

## Initial Setup

### Provisioning:
- Install the Terraform CLI and the IBM Cloud Provider plug-in: https://cloud.ibm.com/docs/terraform?topic=terraform-tf-provider#configure_provider
- Create the infra
```shell
# how to create an API key - https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key
$ export TF_VAR_ibmcloud_api_key=<IBM API KEY>
$ terraform init
$ terraform plan
$ terraform apply
```
- Add the Ports 30000-32767	into the default security group of the VPC to talk Load Balancer with the node ports 
- Deploy resources to the cluster

```shell script
# get the kubeconfig credential for the cluster
$ ibmcloud ks cluster config --cluster k8s-prow

# Create a namespace
$ kubectl create namespace prow
$ kubectl create test-pods

# deploy the secrets from https://github.ibm.com/powercloud/secrets.git
$ git clone https://github.ibm.com/powercloud-secrets/secrets.git
$ kubectl apply -f secrets/projects/k8s-prow/*

# copy the Ingress Subdomain and Secret and modify the resources/* file
$ ibmcloud ks cluster get --cluster k8s-prow | grep Ingress

# Deploy the prow resources
$ kubectl apply -f resources/*.yaml

```

### Importing the terraform state

```shell script
# Get the IKS cluster ID
$ ibmcloud ks cluster ls

$ export TF_VAR_ibmcloud_api_key=<IBM API KEY>
$ terraform import -config=../../modules/iks-cluster ibm_container_vpc_cluster.cluster <IKS_CLUSTER_ID>

```

### Reload the pods with new GH token

```shell script
$ kubectl get pods -n prow --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -E 'hook|deck|tide|statusreconciler|prow\-controller\-manager|crier' | xargs kubectl delete pod -n prow
```