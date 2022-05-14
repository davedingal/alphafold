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
# Downloads, unzips and flattens the PDB database for AlphaFold.
#
# Usage: bash download_pdb_mmcif.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

if ! command -v rsync &> /dev/null ; then
    echo "Error: rsync could not be found. Please install rsync."
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
ROOT_DIR="${DOWNLOAD_DIR}/pdb_mmcif"
MMCIF_DIR="${ROOT_DIR}/mmcif_files"
RAW_DIR="${ROOT_DIR}/mmcif/raw"

TAR_FILE="$2/mmcif.tar.gz"

mkdir -p "${ROOT_DIR}"
if ! [ -f "${ROOT_DIR}/obsolete.dat" ]; then
  curl -XGET "ftp://ftp.wwpdb.org/pub/pdb/data/status/obsolete.dat" > "${ROOT_DIR}/obsolete.dat"
fi

if ! [ -f "${MMCIF_DIR}/download_completed" ]; then
  mkdir -p "${MMCIF_DIR}"
  if [ -f "${TAR_FILE}" ]; then
    ${GUNZIP} "${TAR_FILE}" | tar xf - -C "${MMCIF_DIR}"
    exit 0
  fi

  echo "Running rsync to fetch all mmCIF files (note that the rsync progress estimate might be inaccurate)..."
  echo "If the download speed is too slow, try changing the mirror to:"
  echo "  * rsync.ebi.ac.uk::pub/databases/pdb/data/structures/divided/mmCIF/ (Europe)"
  echo "  * ftp.pdbj.org::ftp_data/structures/divided/mmCIF/ (Asia)"
  echo "or see https://www.wwpdb.org/ftp/pdb-ftp-sites for more download options."
  mkdir -p "${RAW_DIR}"
  rsync --recursive --links --perms --times --compress --info=progress2 --delete --port=33444 \
    rsync.rcsb.org::ftp_data/structures/divided/mmCIF/ \
    "${RAW_DIR}"

  echo "Unzipping all mmCIF files..."
  find "${RAW_DIR}/" -type f -iname "*.gz" -exec gunzip {} +

  echo "Flattening all mmCIF files..."
  find "${RAW_DIR}" -type d -empty -delete  # Delete empty directories.
  for subdir in "${RAW_DIR}"/*; do
    mv "${subdir}/"*.cif "${MMCIF_DIR}"
  done

  rm -rf "${RAW_DIR}"

  touch "${MMCIF_DIR}/download_completed"

  tar cf - -C "${MMCIF_DIR}" . | ${GZIP} > "${TAR_FILE}"
else
  echo "Skipping mmcif rsync."
fi

