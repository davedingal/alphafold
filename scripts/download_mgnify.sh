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
# Downloads and unzips the MGnify database for AlphaFold.
#
# Usage: bash download_mgnify.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
TAR_FILE="$2/mgnify.gz"
ROOT_DIR="${DOWNLOAD_DIR}/mgnify"
# Mirror of:
# ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/peptide_database/2018_12/mgy_clusters.fa.gz
SOURCE_URL="https://storage.googleapis.com/alphafold-databases/casp14_versions/mgy_clusters_2018_12.fa.gz"
BASENAME=$(basename "${SOURCE_URL}")

if [ -d "${ROOT_DIR}" ]; then
  echo "Skipping."
  exit 0
fi

mkdir -p "${ROOT_DIR}"
if [ -f "${TAR_FILE}" ]; then
  cat "${TAR_FILE}" | gunzip > "${ROOT_DIR}/mgy_clusters_2018_12.fa"
  exit 0
fi

python download.py -h storage.googleapis.com --uri /alphafold-databases/casp14_versions/mgy_clusters_2018_12.fa.gz --ssl > "${TAR_FILE}"
cat "${TAR_FILE}" | gunzip > "${ROOT_DIR}/mgy_clusters_2018_12.fa"
