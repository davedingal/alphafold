#!/bin/bash
#SBATCH -c 12 # Number of cores requested
#SBATCH -t 60 # Runtime in minutes
#SBATCH -p gpu_requeue # Partition to submit to
#SBATCH --gres=gpu:1
#SBATCH --mem=85000 # Memory per node in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append # Append when writing files
#SBATCH -o alphafold_%j.out # Standard out goes to this file
#SBATCH -e alphafold_%j.err # Standard err goes to this filehostname

set -e

echo "Running on host $(hostname)"
echo "Loading anaconda"
#module load Anaconda3/2020.11
echo "Initializing anaconda environment"
#conda init bash
#conda activate alphafold_env

echo "Python binary: $(which python)"

usage() {
	echo 'run.sh --data_dir={base directory of databases} --fasta_file={fasta input file} --output_dir={where the output will be saved}'
	echo '  Any trailing or unmatched arguments will be sent to run_alphafold.py (e.g. --model_preset=multimer)"'
	exit 1
}

echo $@
OPTIONS=$(getopt --long data_dir:,fasta_file:,output_dir: -- - $@)
eval set -- "${OPTIONS}"

DATA_DIR=''
FASTA_FILE=''
OUTPUT_DIR=''

# extract options and their arguments into variables.
while true ; do
  case "$1" in
      --data_dir)
        DATA_DIR=$2 ; shift 2 ;;
      --fasta_file)
        FASTA_FILE=$2 ; shift 2 ;;
      --output_dir)
        OUTPUT_DIR=$2 ; shift 2;;
      --) shift ; break ;;
      *) usage;;
  esac
done

if [ -z "${FASTA_FILE}" -o -z "${DATA_DIR}" -o -z "${OUTPUT_DIR}" ]; then
  usage
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

BASE_BIN_DIR=${HOME}/.local/bin/

# ldconfig
echo "Fasta file: ${FASTA_FILE}"
echo "Running alphafold..."
NVIDIA_VISIBLE_DEVICES=all TF_FORCE_UNIFIED_MEMORY=1 XLA_PYTHON_CLIENT_MEM_FRACTION=4.0 python ./run_alphafold.py --data_dir=${DATA_DIR} --uniref90_database_path=${DATA_DIR}/uniref90/uniref90.fasta --mgnify_database_path=${DATA_DIR}/mgnify/mgy_clusters_2018_12.fa --pdb70_database_path=${DATA_DIR}/pdb70/pdb70 --template_mmcif_dir=${DATA_DIR}/pdb_mmcif/mmcif_files --obsolete_pdbs_path=${DATA_DIR}/pdb_mmcif/obsolete.dat --bfd_database_path=${DATA_DIR}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --uniclust30_database_path=${DATA_DIR}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 --pdb_seqres_database_path=${DATA_DIR}/pdb_seqres/pdb_seqres.txt --uniprot_database_path=${DATA_DIR}/uniprot/uniprot.fasta --small_bfd_database_path=${DATA_DIR}/small_bfd/bfd-first_non_consensus_sequences.fasta --output_dir=${OUTPUT_DIR} --max_template_date=2020-05-14 --jackhmmer_binary_path=${BASE_BIN_DIR}jackhmmer --hhblits_binary_path=${BASE_BIN_DIR}hhblits --hhsearch_binary_path=${BASE_BIN_DIR}hhsearch --kalign_binary_path=${BASE_BIN_DIR}kalign --fasta_paths=${FASTA_FILE} --logtostderr --use_precomputed_msas=true --use_gpu_relax=true $@

EXIT_STATUS=$?

echo "Alphafold finished with exit status ${EXIT_STATUS}"

exit $EXIT_STATUS
