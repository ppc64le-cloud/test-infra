### How to manually update the configmaps

```shell script
$ kubectl create configmap config -n prow --from-file=config.yaml=config.yaml -o=yaml --dry-run | kubectl replace -f -
$ kubectl create configmap plugins -n prow --from-file=plugins.yaml=plugins.yaml -o=yaml --dry-run | kubectl replace -f -
```