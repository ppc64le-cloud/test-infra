#!/usr/bin/env bash
# Inspired by https://github.com/kubernetes/test-infra/blob/047b0a0596f7d42b909405c0b8ed4366de2bef72/prow/pj-on-kind.sh
# Required kubectl
# Right now this work only on the x86 platform(Linux, MacOS)

set -o errexit
set -o nounset
set -o pipefail


function main() {
  parseArgs "$@"

  # Generate PJ and Pod.
  docker run -i --rm -v "${PWD}:${PWD}" -v "${config}:${config}" ${job_config_mnt} -w "${PWD}" us-docker.pkg.dev/k8s-infra-prow/images/mkpj "--config-path=${config}" "--job=${job}" ${job_config_flag} > "${PWD}/pj.yaml"
  docker run -i --rm -v "${PWD}:${PWD}" -w "${PWD}" us-docker.pkg.dev/k8s-infra-prow/images/mkpod --build-id=snowflake "--prow-job=${PWD}/pj.yaml" --local "--out-dir=${out_dir}/${job}" > "${PWD}/pod.yaml"

  echo "Applying pod to the mkpod cluster. Configure kubectl for the mkpod cluster with:"
  echo "Press Control+c for exiting the script"
  pod=$(kubectl apply -f "${PWD}/pod.yaml" | cut -d ' ' -f 1)
  if [[ ! -z ${purpose} ]];then
    if [[ ! -f "${PWD}/pod_table.txt" ]];then
      echo -e "Pod UUID\t\t\t\t\tJob\t\t\tPurpose\t\t\tTimestamp" >> "${PWD}/pod_table.txt"
    fi
    echo "The file pod_table.txt in present working directory contains records
of pods created by testpj jobs"
    echo -e "${pod:4} \t ${job} \t ${purpose} \t $(kubectl get "${pod}" -o jsonpath='{.metadata.creationTimestamp}')" >> "${PWD}/pod_table.txt"
  fi
  kubectl get "${pod}" -w
}

function parseArgs() {
  while [[ $# != 0 ]]
  do
    case "$1" in
      -j)
          job=$2
          ;;
     -p)
         purpose=$2
         ;;
      -h)
          echo -e "Usage: testpj -j job [-p purpose]\nJob: Job to be run. Must be one of the jobs in JOB_CONFIG_PATH\nPurpose: User-defined string denoting the purpose for which this job is being run"
          exit 0
          ;;
      *)
          echo "Invalid option: $1"
          exit 2
          ;;
    esac
    if [[ -z $2 || ${2:0:1} == "-" ]];then
      echo -e "Value of parameter $1 must be specified!\nUsage: testpj -j job [-p purpose]"
      exit 2
    fi
  shift
  shift
  done
  config="${CONFIG_PATH:-}"
  job_config_path="${JOB_CONFIG_PATH:-}"
  out_dir="${OUT_DIR:-/tmp/prowjob-out}"
  #node_dir="${NODE_DIR:-/tmp/kind-node}"

  echo "job=${job}"
  echo "CONFIG_PATH=${config}"
  echo "JOB_CONFIG_PATH=${job_config_path}"
  echo "OUT_DIR=${out_dir}"
  #echo "NODE_DIR=${node_dir}"

  if [[ -z "${job}" ]]; then
    echo -e "Job name must be specified!\nUsage: testpj -j job [-p purpose]"
    exit 2
  fi
  if [[ -z ${purpose+x} ]]; then
    purpose=""
  fi
  if [[ -z "${config}" ]]; then
    echo "Must specify config.yaml location via CONFIG_PATH env var."
    exit 2
  fi
  job_config_flag=""
  job_config_mnt=""
  if [[ -n "${job_config_path}" ]]; then
    job_config_flag="--job-config-path=${job_config_path}"
    job_config_mnt="-v ${job_config_path}:${job_config_path}"
  fi
}

main "$@"
