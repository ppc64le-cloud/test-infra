### Deploy Prow

1. Create Namespaces

```shell
$ kubectl create namespace prow
$ kubectl create namespace test-pods
# non-mandetory, used for the grafana dashboard
$ kubectl create namespace grafana-dashboard
```

2. Import the tls certificate from the cert-manager

3. Deploy the configs:
```shell
$ kubectl create configmap config -n prow --from-file=config.yaml=./config/prow/config.yaml -o=yaml --dry-run=client | kubectl create -n prow -f -
$ kubectl create configmap plugins -n prow --from-file=plugins.yaml=./config/prow/plugins.yaml -o=yaml --dry-run=client | kubectl create -n prow -f -
# Dummy configmap to proceed the prow deployment
$ kubectl create configmap job-config -n prow
```

4. Deploy the job configs:

```shell
$ ./hack/update-job-config.sh
```

5. Deploy the buildfarms configuration - [here](./config/prow/buildfarms/README.md)

6. Deploy all the required secrets

>Note: Maintained in the IBM's internal GHE repository

7. Deploy the prow

```shell
$ cd cluster
$ kubectl apply -f .
```

### How to manually update the configmaps

```shell script
$ kubectl create configmap config -n prow --from-file=config.yaml=config.yaml -o=yaml --dry-run | kubectl replace -f -
$ kubectl create configmap plugins -n prow --from-file=plugins.yaml=plugins.yaml -o=yaml --dry-run | kubectl replace -f -
```