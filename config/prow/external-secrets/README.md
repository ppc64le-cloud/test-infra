## Steps for fetching secret from Secret Manager to k8s cluster

### 1. Deploying external Secrets Operator on cluster
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets

Note: Though the operator runs in one namespace, crds are available cluster wide and enables us to fetch the secrets in different namespaces.
Updating the secret store with provider details is what it all needs.

### 2. Creating ibm-secret in cluster for connecting to IBM Cloud Secrets Manager
`kubectl create secret generic ibm-secret --from-literal=apiKey='API_KEY_VALUE' -n <namespace>`

### 3. Update the secret store
kubectl apply -f secretstore_update.yaml -n <namespace>

### 4. Create an external secret
kubectl apply -f <external_secrets_name>.yaml -n <namespace>
