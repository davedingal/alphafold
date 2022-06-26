#!/bin/bash
#SBATCH -n 12 # Number of cores requested
#SBATCH -t 60 # Runtime in minutes
#SBATCH -p gpu-a100 # Partition to submit to
#SBATCH --mem=85000 # Memory per node in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append # Append when writing files

FASTA_FILE=$1
OUTPUT_DIR=$WORK/af_outputs/$(basename $FASTA_FILE .fasta)/

mkdir -p $OUTPUT_DIR

cd $WORK/alphafold/
./run.sh --data_dir=$SCRATCH/alphafold_dbs/ --output_dir=$WORK/af_outputs/ --fasta_file=$1 > $OUTPUT_DIR/stdout.txt 2> $OUTPUT_DIR/stderr.txt

