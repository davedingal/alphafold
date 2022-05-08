#!/bin/bash
#SBATCH -c 12 # Number of cores requested
#SBATCH -t 60 # Runtime in minutes
#SBATCH -p gpu_requeue # Partition to submit to
#SBATCH --gres=gpu:1
#SBATCH --mem=85000 # Memory per node in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append # Append when writing files
#SBATCH -o alphafold_%j.out # Standard out goes to this file
#SBATCH -e alphafold_%j.err # Standard err goes to this filehostname

echo "Running on host $(hostname)"
echo "Loading anaconda"
#module load Anaconda3/2020.11
echo "Initializing anaconda environment"
#conda init bash
#conda activate alphafold_env

echo "Python binary: $(which python)"

env > env2.txt

DATA_DIR=$1

if ! [ -d "${DATA_DIR}" ]; then
	echo 'You must specify the data directory to run this program.'
	exit 1
fi

if [ -z "$2" ]; then
	echo "You must specify the fasta paths as the second argument."
	exit 1
fi

if [ -z "$3" ]; then
	echo "Output directory not specified."
	exit 1
fi

mkdir -p $3

BASE_BIN_DIR=${HOME}/.local/bin/

# ldconfig
echo "Running alphafold..."
NVIDIA_VISIBLE_DEVICES=all TF_FORCE_UNIFIED_MEMORY=1 XLA_PYTHON_CLIENT_MEM_FRACTION=4.0 python ./run_alphafold.py --data_dir=${DATA_DIR} --uniref90_database_path=${DATA_DIR}/uniref90/uniref90.fasta --mgnify_database_path=${DATA_DIR}/mgnify/mgy_clusters_2018_12.fa --pdb70_database_path=${DATA_DIR}/pdb70/pdb70 --template_mmcif_dir=${DATA_DIR}/pdb_mmcif/mmcif_files --obsolete_pdbs_path=${DATA_DIR}/pdb_mmcif/obsolete.dat --bfd_database_path=${DATA_DIR}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --uniclust30_database_path=${DATA_DIR}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 --output_dir=$3 --max_template_date=2020-05-14 --jackhmmer_binary_path=${BASE_BIN_DIR}jackhmmer --hhblits_binary_path=${BASE_BIN_DIR}hhblits --hhsearch_binary_path=${BASE_BIN_DIR}hhsearch --kalign_binary_path=${BASE_BIN_DIR}kalign --model_names=model_1,model_2,model_3,model_4,model_5 --fasta_paths=$2

echo "Alphafold finished with exit status $?"
