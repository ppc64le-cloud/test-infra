#!/bin/bash

set -e

set -o allexport
source env.list
source env-distrib.list

DIR_TEST="/workspace/test_docker-ce-${DOCKER_VERS}_containerd-${CONTAINERD_VERS}"
PATH_DOCKERFILE="/workspace/docker_ce_build_ppc64/images/docker-in-docker/test"
PATH_TEST_ERRORS="${DIR_TEST}/test_errors.txt"

echo "# Dockerd #" 2>&1 | tee -a ${PATH_LOG}
sh ${PATH_SCRIPTS}/dockerd-entrypoint.sh &
source ${PATH_SCRIPTS}/dockerd-starting.sh

if [ ! -z "$pid" ]
then
  if ! test -d ${DIR_TEST}
  then
    mkdir -p "${DIR_TEST}"
  fi
  if ! test -f ${PATH_TEST_ERRORS}
  then 
    touch ${PATH_TEST_ERRORS}
  else
    rm ${PATH_TEST_ERRORS}
    touch ${PATH_TEST_ERRORS}
  fi
  for PACKTYPE in DEBS RPMS
  do
    echo "## Looking for distro type: ${PACKTYPE} ##" 2>&1 | tee -a ${PATH_LOG}

    for DISTRO in ${!PACKTYPE} 
    do
      echo "### Looking for ${DISTRO} ###" 2>&1 | tee -a ${PATH_LOG}
      DISTRO_NAME="$(cut -d'-' -f1 <<<"${DISTRO}")"
      DISTRO_VERS="$(cut -d'-' -f2 <<<"${DISTRO}")"
      IMAGE_NAME="t_docker_${DISTRO_NAME}_${DISTRO_VERS}"
      CONT_NAME="t_docker_run_${DISTRO_NAME}_${DISTRO_VERS}"
      BUILD_LOG="build_${DISTRO_NAME}_${DISTRO_VERS}.log"
      TEST_LOG="test_${DISTRO_NAME}_${DISTRO_VERS}.log"

      export DISTRO_NAME

      # get in the tmp directory with the docker-ce and containerd packages and the Dockerfile
      if ! test -d tmp
      then
        mkdir tmp
      else 
        rm -rf tmp
        mkdir tmp
      fi
      pushd tmp
      echo "### # Copying the packages and the dockerfile for ${DISTRO} # ###" 2>&1 | tee -a ${PATH_LOG}
      # copy the docker_ce
      cp /workspace/docker-ce-${DOCKER_VERS}/bundles-ce-${DISTRO_NAME}-${DISTRO_VERS}-ppc64le.tar.gz /workspace/tmp
      # copy the containerd
      cp /workspace/containerd-${CONTAINERD_VERS}/${DISTRO_NAME}/${DISTRO_VERS}/ppc64*/containerd*ppc64*.* /workspace/tmp
      # copy the Dockerfile
      cp ${PATH_DOCKERFILE}-${PACKTYPE}/Dockerfile /workspace/tmp
      # copy the test_launch.sh which will be copied in /usr/local/bin
      # copy not necessary of the dockerd-starting.sh and the dockerd-entrypoint.sh
      cp ${PATH_SCRIPTS}/test_launch.sh /workspace/tmp
      # check we have docker-ce packages and containerd packages and Dockerfile

      echo "### # Building the test image: ${IMAGE_NAME} # ###" 2>&1 | tee -a ${PATH_LOG}
      docker build -t ${IMAGE_NAME} --build-arg DISTRO_NAME=${DISTRO_NAME} --build-arg DISTRO_VERS=${DISTRO_VERS} --build-arg DOCKER_VERS=${DOCKER_VERS} --build-arg CONTAINERD_VERS=${CONTAINERD_VERS} . 2>&1 | tee ${DIR_TEST}/${BUILD_LOG}

      if [[ $? -ne 0 ]]; then
        echo "ERROR: docker build failed for ${DISTRO}, see details from '${BUILD_LOG}'" 2>&1 | tee -a ${PATH_LOG}
        continue
      else
        echo "docker build done" 2>&1 | tee -a ${PATH_LOG}
      fi

      echo "### # Running the tests from the container: ${CONT_NAME} # ###" 2>&1 | tee -a ${PATH_LOG}
      docker run --env SECRET_AUTH --env DISTRO_NAME --env PATH_SCRIPTS -d -v /workspace:/workspace --privileged --name $CONT_NAME ${IMAGE_NAME}

      status_code="$(docker container wait $CONT_NAME)"
      if [[ ${status_code} -ne 0 ]]; then
        echo "ERROR: The test suite failed for ${DISTRO}. See details from '${TEST_LOG}'" 2>&1 | tee -a ${PATH_LOG}
        docker logs $CONT_NAME 2>&1 | tee ${DIR_TEST}/${TEST_LOG}
      else
        docker logs $CONT_NAME 2>&1 | tee ${DIR_TEST}/${TEST_LOG}
        echo "tests done" 2>&1 | tee -a ${PATH_LOG}
      fi

      echo "### # Cleanup: ${CONT_NAME} # ###" 2>&1 | tee -a ${PATH_LOG}
      docker stop ${CONT_NAME}
      docker rm ${CONT_NAME}
      docker image rm ${IMAGE_NAME}
      popd
      rm -rf tmp
      # check the logs
      if test -f ${DIR_TEST}/${TEST_LOG}
      then
        echo "### # Checking the logs # ###" 2>&1 | tee -a ${PATH_LOG}
        echo "DISTRO ${DISTRO_NAME} ${DISTRO_VERS}" 2>&1 | tee -a ${PATH_TEST_ERRORS}
        
        TEST_1=$(eval "cat ${DIR_TEST}/${TEST_LOG} | grep exitCode | awk 'NR==2' | rev | cut -d' ' -f 1")
        echo "TestDistro : ${TEST_1}" 2>&1 | tee -a ${PATH_TEST_ERRORS} 

        TEST_2=$(eval "cat ${DIR_TEST}/${TEST_LOG} | grep exitCode | awk 'NR==3' | rev | cut -d' ' -f 1")
        echo "TestDistroInstallPackage : ${TEST_2}" 2>&1 | tee -a ${PATH_TEST_ERRORS} 

        TEST_3=$(eval "cat ${DIR_TEST}/${TEST_LOG} | grep exitCode | awk 'NR==4' | rev | cut -d' ' -f 1")
        echo "TestDistroPackageCheck : ${TEST_3}" 2>&1 | tee -a ${PATH_TEST_ERRORS} 

        [[ "$TEST_1" -eq "0" ]] && [[ "$TEST_2" -eq "0" ]] && [[ "$TEST_3" -eq "0" ]]
        echo "All : $?" 2>&1 | tee -a ${PATH_TEST_ERRORS} 
        tail -5 ${PATH_TEST_ERRORS} 2>&1 | tee -a ${PATH_LOG}
      else 
        echo "There is no ${TEST_LOG} file." 2>&1 | tee -a ${PATH_LOG}
      fi
    done
  done
fi
