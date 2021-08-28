#!/bin/bash

DATA_DIR=$1

if ! [ -d "${DATA_DIR}" ]; then
	echo 'You must specify the data directory to run this program.'
	exit 1
fi

mkdir -p output/
ldconfig
NVIDIA_VISIBLE_DEVICES=all WHATEVER=test python ./run_alphafold.py --data_dir=${DATA_DIR} --uniref90_database_path=${DATA_DIR}/uniref90/uniref90.fasta --mgnify_database_path=${DATA_DIR}/mgnify/mgy_clusters_2018_12.fa --pdb70_database_path=${DATA_DIR}/pdb70/pdb70 --template_mmcif_dir=${DATA_DIR}/pdb_mmcif/mmcif_files --obsolete_pdbs_path=${DATA_DIR}/pdb_mmcif/obsolete.dat --bfd_database_path=${DATA_DIR}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --uniclust30_database_path=${DATA_DIR}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 --output_dir=./output/ --max_template_date=2020-05-14 --model_names=model_1,model_2,model_3,model_4,model_5
