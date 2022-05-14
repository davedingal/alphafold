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
# Downloads and unzips the Small BFD database for AlphaFold.
#
# Usage: bash download_small_bfd.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
TAR_FILE="$2/small_bfd.gz"
ROOT_DIR="${DOWNLOAD_DIR}/small_bfd"
SOURCE_URL="https://storage.googleapis.com/alphafold-databases/reduced_dbs/bfd-first_non_consensus_sequences.fasta.gz"
BASENAME=$(basename "${SOURCE_URL}")

if [ -d "${ROOT_DIR}" ]; then
  echo "Skipping."
  exit 0
fi

mkdir -p "${ROOT_DIR}"
if [ -f "${TAR_FILE}" ]; then
  cat "${TAR_FILE}" | gunzip > "${ROOT_DIR}/bfd-first_non_consensus_sequences.fasta"
  exit 0
fi

python download.py --ssl -h storage.googleapis.com --uri /alphafold-databases/reduced_dbs/bfd-first_non_consensus_sequences.fasta.gz > "${TAR_FILE}"
cat "${TAR_FILE}" | gunzip > "${ROOT_DIR}/bfd-first_non_consensus_sequences.fasta"
