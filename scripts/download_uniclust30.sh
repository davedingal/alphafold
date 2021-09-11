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
# Downloads and unzips the Uniclust30 database for AlphaFold.
#
# Usage: bash download_uniclust30.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

DOWNLOAD_DIR="$1"
ROOT_DIR="${DOWNLOAD_DIR}/uniclust30"
# Mirror of:
# http://wwwuser.gwdg.de/~compbiol/uniclust/2018_08/uniclust30_2018_08_hhsuite.tar.gz
SOURCE_URL="https://storage.googleapis.com/alphafold-databases/casp14_versions/uniclust30_2018_08_hhsuite.tar.gz"
BASENAME=$(basename "${SOURCE_URL}")

if [ -d "${ROOT_DIR}" ]; then
  echo "Skipping."
  exit 0
fi

mkdir -p "${ROOT_DIR}"
python download.py -h storage.googleapis.com --uri /alphafold-databases/casp14_versions/uniclust30_2018_08_hhsuite.tar.gz --ssl | tar xzf /dev/stdin -C "${ROOT_DIR}"
