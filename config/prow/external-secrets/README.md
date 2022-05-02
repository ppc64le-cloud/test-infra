## Steps for fetching secret from Secret Manager to k8s cluster

### 1. Deploying external Secrets Operator on cluster
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets

Note: Though the operator runs in one namespace, crds are available cluster wide and enables us to fetch the secrets in different namespaces.
Updating the secret store with provider details is what it all needs.

### 2. Create a secret in cluster with the IBMCloud APIKey for connecting to IBM Cloud Secrets Manager
The spec by name `ibm-cloud-credentials_secret.yaml` in the https://github.ibm.com/powercloud-secrets/secrets repo has the required data.
```
git clone git@github.ibm.com:powercloud-secrets/secrets.git
kubectl apply -f ./secrets/projects/k8s-prow/ibm-cloud-credentials_secret.yaml
```

### 3. Update the secret store
Update the cluster scoped ClusterSecretStore with the IBM provider.
`kubectl apply -f secretstore_update.yaml`

### 4. Create an external secret
`kubectl apply -f <external_secrets_name>.yaml -n <namespace>`
