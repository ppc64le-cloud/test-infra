#!/bin/bash
# script to get the env.list file and the dockertest from the ppc64le-docker COS bucket

set -ue

PATH_COS="/mnt"
PATH_PASSWORD="/root/.s3fs_cos_secret"

COS_BUCKET="ppc64le-docker"
URL_COS="https://s3.us-south.cloud-object-storage.appdomain.cloud"
FILE_ENV="env.list"
PATH_DOCKERTEST="/workspace/test/src/github.ibm.com/powercloud"

echo ":" > ${PATH_PASSWORD}_buffer
echo "$S3_SECRET_AUTH" >> ${PATH_PASSWORD}_buffer
tr -d '\n' < ${PATH_PASSWORD}_buffer > ${PATH_PASSWORD}
chmod 600 ${PATH_PASSWORD}
rm ${PATH_PASSWORD}_buffer
apt update && apt install -y s3fs
s3fs --version 2>&1 | tee -a ${PATH_LOG_PROWJOB}

mkdir -p ${PATH_COS}/s3_${COS_BUCKET}
# mount the cos bucket
s3fs ${COS_BUCKET} ${PATH_COS}/s3_${COS_BUCKET} -o url=${URL_COS} -o passwd_file=${PATH_PASSWORD} -o ibm_iam_auth

ls ${PATH_COS}/s3_${COS_BUCKET}/prow-docker/ 2>&1 | tee -a ${PATH_LOG_PROWJOB}

# copy the env.list to the local /workspace
cp ${PATH_COS}/s3_${COS_BUCKET}/prow-docker/${FILE_ENV} /workspace/${FILE_ENV} 

# copy the dockertest repo to the local /workspace
mkdir -p ${PATH_DOCKERTEST}
cp -r ${PATH_COS}/s3_${COS_BUCKET}/prow-docker/dockertest ${PATH_DOCKERTEST}/dockertest

set -o allexport
source /workspace/${FILE_ENV}

if [[ ${CONTAINERD_VERS} = "0" ]]
then
    cp -r ${PATH_COS}/s3_${COS_BUCKET}/prow-docker/containerd-* /workspace/
fi

# check we have the env.list, the dockertest and the containerd packages if CONTAINERD_VERS = 0
if ! test -f /workspace/${FILE_ENV} && test -d ${PATH_DOCKERTEST}/dockertest
then
    echo "The env.list and/or the dockertest directory have not been copied." 2>&1 | tee -a ${PATH_LOG_PROWJOB}
    exit 1
fi

if [[ ${CONTAINERD_VERS} = "0" ]]
then
    if test -d /workspace/containerd-*
    then
        echo "The containerd packages have been copied." 2>&1 | tee -a ${PATH_LOG_PROWJOB}
        exit 0
    else
        echo "The containerd packages have not been copied." 2>&1 | tee -a ${PATH_LOG_PROWJOB}
        exit 1
    fi
else
    echo "The env.list and the dockertest directory have been copied." 2>&1 | tee -a ${PATH_LOG_PROWJOB}
    exit 0
fi