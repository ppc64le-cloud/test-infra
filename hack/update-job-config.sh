#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")/..
tmp_dir=$(mktemp -d)

pushd "${ROOT_DIR}"

find_yaml_files() {
  find config/jobs -name '*.yaml'
}

cm_file_content=""

for job_file in $(find_yaml_files)
do
  job=$(basename "${job_file}")
  gzip "${job_file}" --stdout > "${tmp_dir}"/"${job}"
  cm_file_content="${cm_file_content} --from-file=${job}=${tmp_dir}/${job}"
done

kubectl create cm job-config "${cm_file_content}" -n prow -o=yaml --dry-run=client | kubectl apply -f -
