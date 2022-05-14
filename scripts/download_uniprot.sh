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
# Downloads, unzips and merges the SwissProt and TrEMBL databases for
# AlphaFold-Multimer.
#
# Usage: bash download_uniprot.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

# check if pigz is installed and use it if possible - significantly faster zipping and unzipping
GZIP=gzip
GUNZIP=gunzip
if command -v pigz &> /dev/null ; then
  GZIP="pigz -c"
  GUNZIP="pigz -c -d"
else
  echo "Install pigz for faster unzipping/zipping"
fi

DOWNLOAD_DIR="$1"
TAR_DIR="$2"
ROOT_DIR="${DOWNLOAD_DIR}/uniprot"

TREMBL_SOURCE_URL="ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz"
TREMBL_GZIP="${TAR_DIR}/$(basename "${TREMBL_SOURCE_URL}")"
TREMBL_BASENAME=$(basename "${TREMBL_SOURCE_URL}")
TREMBL_UNZIPPED_BASENAME="${TREMBL_BASENAME%.gz}"

SPROT_SOURCE_URL="ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"
SPROT_GZIP="${TAR_DIR}/$(basename "${SPROT_SOURCE_URL}")"
SPROT_BASENAME=$(basename "${SPROT_SOURCE_URL}")
SPROT_UNZIPPED_BASENAME="${SPROT_BASENAME%.gz}"

if [ -d "${ROOT_DIR}" ]; then
    echo "Skipping"
    exit 0
fi

if ! [ -f "${TREMBL_GZIP}" ]; then
    curl -XGET "${TREMBL_SOURCE_URL}" > "${TREMBL_GZIP}"
fi

if ! [ -f "${SPROT_GZIP}" ]; then
    curl -XGET "${SPROT_SOURCE_URL}" > "${SPROT_GZIP}"
fi

mkdir -p "${ROOT_DIR}"
cat "${TREMBL_GZIP}" | ${GUNZIP} > "${ROOT_DIR}/uniprot.fasta"
cat "${SPROT_GZIP}" | ${GUNZIP} >> "${ROOT_DIR}/uniprot.fasta"
