#!/bin/bash
#
# Copyright 2021 DeepMind Technologies Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Downloads and unzips the AlphaFold parameters.
#
# Usage: bash download_alphafold_params.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
TAR_FILE="$2/params.tar.gz"
ROOT_DIR="${DOWNLOAD_DIR}/params"
SOURCE_URL="https://storage.googleapis.com/alphafold/alphafold_params_2022-03-02.tar"
BASENAME=$(basename "${SOURCE_URL}")

if [ -d "${ROOT_DIR}" ]; then
  echo "Skipping."
  exit 0
fi

mkdir -p "${ROOT_DIR}"
if [ -f "${TAR_FILE}" ]; then
  tar xzf "${TAR_FILE}" -C "${ROOT_DIR}"
  exit 0
fi

python download.py -h storage.googleapis.com --ssl --uri /alphafold/alphafold_params_2021-07-14.tar | gzip > "${TAR_FILE}"
tar xzf "${TAR_FILE}" -C "${ROOT_DIR}" --no-seek
