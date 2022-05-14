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
# Downloads and unzips the PDB70 database for AlphaFold.
#
# Usage: bash download_pdb70.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
TAR_FILE="$2/pdb70.tar.gz"
ROOT_DIR="${DOWNLOAD_DIR}/pdb70"
SOURCE_URL="http://wwwuser.gwdg.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/old-releases/pdb70_from_mmcif_200401.tar.gz"

if [ -d "${ROOT_DIR}" ]; then
  echo "Skipping."
  exit 0
fi

mkdir -p "${ROOT_DIR}"
if ! [ -f "${TAR_FILE}" ]; then
  python download.py -h wwwuser.gwdg.de --uri /~compbiol/data/hhsuite/databases/hhsuite_dbs/old-releases/pdb70_from_mmcif_200401.tar.gz --ssl > "${TAR_FILE}"
fi

tar xzf "${TAR_FILE}" -C "${ROOT_DIR}"
