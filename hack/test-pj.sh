#!/usr/bin/env bash
# Inspired by https://github.com/kubernetes/test-infra/blob/047b0a0596f7d42b909405c0b8ed4366de2bef72/prow/pj-on-kind.sh
# Required kubectl
# Rightnow this work only on the x86 platform(Linux, MacOS)

set -o errexit
set -o nounset
set -o pipefail


function main() {
  parseArgs "$@"

  # Generate PJ and Pod.
  docker run -i --rm -v "${PWD}:${PWD}" -v "${config}:${config}" ${job_config_mnt} -w "${PWD}" gcr.io/k8s-prow/mkpj "--config-path=${config}" "--job=${job}" ${job_config_flag} > "${PWD}/pj.yaml"
  docker run -i --rm -v "${PWD}:${PWD}" -w "${PWD}" gcr.io/k8s-prow/mkpod --build-id=snowflake "--prow-job=${PWD}/pj.yaml" --local "--out-dir=${out_dir}/${job}" > "${PWD}/pod.yaml"

  echo "Applying pod to the mkpod cluster. Configure kubectl for the mkpod cluster with:"
  echo "Press Control+c for exiting the script"
  pod=$(kubectl apply -f "${PWD}/pod.yaml" | cut -d ' ' -f 1)
  kubectl get "${pod}" -w
}

function parseArgs() {
  job="${1:-}"
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
    echo "Must specify a job name as the first argument."
    exit 2
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
