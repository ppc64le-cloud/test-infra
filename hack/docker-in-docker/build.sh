#!/bin/bash
# Script building the docker-ce and containerd packages

set -ue

echo "# Dockerd #" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
sh ${PATH_SCRIPTS}/dockerd-entrypoint.sh &
. ${PATH_SCRIPTS}/dockerd-starting.sh

set -o allexport
source env.list
source env-distrib.list

if [ -z "$pid" ]
then
  echo "There is no docker daemon." 2>&1 | tee -a ${PATH_LOG_PROWJOB}
  exit 1
else
  # PART TO REMOVE
  if ! test -d /root/.docker 
  then
    echo "## Docker login ##" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
    mkdir /root/.docker
    echo "$DOCKER_SECRET_AUTH" > /root/.docker/config.json
  fi
  if grep -Fq "index.docker.io" /root/.docker/config.json
  then
    echo "## Building docker-ce ##" 2>&1 | tee -a ${PATH_LOG_PROWJOB}

    DIR_DOCKER="/workspace/docker-ce-${DOCKER_VERS}"
    mkdir ${DIR_DOCKER}

    # Workaround for builkit cache issue where fedora-32/Dockerfile
    # (or the 1st Dockerfile used by buildkit) is used for all fedora's version
    # See https://github.com/moby/buildkit/issues/1368
    patchDockerFiles() {
      Dockfiles="$(find $1  -name 'Dockerfile')"
      d=$(date +%s)
      i=0
      for file in ${Dockfiles}; do
          i=$(( i + 1 ))
          echo "patching timestamp for ${file}"
          touch -d @$(( d + i )) "${file}"
      done
    }

    DIR_PACKAGING="docker-ce-packaging"

    mkdir -p ${DIR_PACKAGING}
    pushd ${DIR_PACKAGING}

    git init
    git remote add origin  https://github.com/docker/docker-ce-packaging.git
    git fetch --depth 1 origin ${PACKAGING_REF}
    git checkout FETCH_HEAD

    make REF=${DOCKER_VERS} checkout
    popd

    pushd docker-ce-packaging/deb
    patchDockerFiles .
    for DEB in ${DEBS}
    do
      echo "= Building for:${DEB} =" 2>&1 | tee -a ${PATH_LOG_PROWJOB}

      VERSION=${DOCKER_VERS} make debbuild/bundles-ce-${DEB}-ppc64le.tar.gz
    
      if test -f debbuild/bundles-ce-${DEB}-ppc64le.tar.gz
      then
        echo "${DEB} built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      else
        echo "${DEB} not built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      fi
    done
    popd

    pushd docker-ce-packaging/rpm
    patchDockerFiles .
    for RPM in ${RPMS}
    do
      echo "== Building for:${RPM} ==" 2>&1 | tee -a ${PATH_LOG_PROWJOB}

      VERSION=${DOCKER_VERS} make rpmbuild/bundles-ce-${RPM}-ppc64le.tar.gz

      if test -f rpmbuild/bundles-ce-${RPM}-ppc64le.tar.gz
      then
        echo "${RPM} built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      else
        echo "${RPM} not built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      fi
    done
    popd

    echo "=== Copying packages to ${DIR_DOCKER} ===" 2>&1 | tee -a ${PATH_LOG_PROWJOB}

    cp -r docker-ce-packaging/deb/debbuild/* ${DIR_DOCKER}
    cp -r docker-ce-packaging/rpm/rpmbuild/* ${DIR_DOCKER}
    rm -rf docker-ce-packaging
    ls ${DIR_DOCKER} 2>&1 | tee -a ${PATH_LOG_PROWJOB}

    if [[ ${CONTAINERD_VERS} != "0" ]]
    # if CONTAINERD_VERS is equal to a version of containerd we want to build
    then
      echo "### Building containerd ###" 2>&1 | tee -a ${PATH_LOG_PROWJOB}

      DIR_CONTAINERD="/workspace/containerd-${CONTAINERD_VERS}"
      mkdir ${DIR_CONTAINERD}

      git clone https://github.com/docker/containerd-packaging.git

      pushd containerd-packaging

      DISTROS="${DEBS//-/:} ${RPMS//-/:}"

      for DISTRO in $DISTROS
      do
        make REF=${CONTAINERD_VERS} docker.io/library/${DISTRO}

        if test -d build/${DISTRO}
        then
          echo "${DISTRO} built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
        else
          echo "${DISTRO} not built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
        fi
      done

      popd

      cp -r containerd-packaging/build/* ${DIR_CONTAINERD}
      rm -rf containerd-packaging
      ls ${DIR_CONTAINERD} 2>&1 | tee -a ${PATH_LOG_PROWJOB}
    fi

    # Check if the docker-ce packages have been built
    ls ${DIR_DOCKER}/*
    if [[ $? -ne 0 ]]
    then
      # No packages built
      echo "No packages built for docker" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      BOOL_DOCKER=0
    else
      # Packages built
      BOOL_DOCKER=1
    fi

    # Check if the containerd packages have been built
    ls ${DIR_CONTAINERD}/*
    if [[ $? -ne 0 ]]
    then
      # No packages built
      echo "No packages built for containerd" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      BOOL_CONTAINERD=0
    else
      # Packages built
      BOOL_CONTAINERD=1
    fi

    # Check if all packages have been built
    if [[ ${BOOL_DOCKER} -eq 0 ]] || [[ ${BOOL_CONTAINERD} -eq 0 ]]
    # if there is no packages built for docker or no packages built for containerd
    then 
      echo "No packages built for either docker, or containerd" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      exit 1
    elif [[ ${BOOL_DOCKER} -eq 1 ]] && [[ ${BOOL_CONTAINERD} -eq 1 ]]
    # if there are packages built for docker and packages built for containerd
    then
      echo "All packages built" 2>&1 | tee -a ${PATH_LOG_PROWJOB}
      exit 0
    fi
  fi
fi
