# ibm-cloud

This is an image which is used for accessing the IBM cloud, includes following content:

- ibmcloud command
- ibmcloud plugins
    - powervs
- python
- python modules for ibm cloud

## How to build

```shell script
$ docker build -t quay.io/powercloud/ibm-cloud:latest .

$ docker push quay.io/powercloud/ibm-cloud:latest
```

<!--
TODO: Build logic not to install the missing libraries on ppc64le platform
-->
> Note: This is supported only on x86 platform because few of the required python libraries are available only in x86 platform 