To triggerer this job:

```
#run the ./hack/test-pj.sh script in the test-pods namespace
$ CONFIG_PATH=$(pwd)/config/prow/config.yaml JOB_CONFIG_PATH=$(pwd)/config/jobs/ppc64le-cloud/build-bot/buildbot-postsubmit.yaml ./hack/test-pj.sh postsubmit-buildbot-job
