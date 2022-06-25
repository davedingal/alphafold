# Connecting to TACC

## What is TACC?

TACC is a computing cluster hosted by UT Austin for Texas-based researchers and scientists. All of TACC's systems are connected through a high-speed network to a 20-Petabyte global share work file system. All users are allocated 1 Terabyte that is accessible from all HPC and visualization resources including compute nodes. The Dingal lab is allocated node-hours in Lonestar6, which is composed of 560 compute nodes and 16 GPU nodes. Lonestar6 employs Dell Servers with AMD's EPYC Milan processor, Mellanox's HDR Infiniband technology, and 8 PB of BeeGFS based storage on Dell storage hardware. Additionally, Lonestar6 supports GPU nodes utilizing NVIDIA's A100 GPUs to support machine learning workflows such as Alphafold and other GPU-enabled applications. Each compute node has two AMD EPYC 7763 64-core processors (Milan) and 256 GB of DDR4 memory. Each GPU node also contains two AMD EPYC processes and two NVIDIA A100 GPUs each with 40 GB of high bandwidth memory (HBM2).

## Getting connected

To get connected to TACC, you must login to [the TACC user portal](https://portal.tacc.utexas.edu/home) - using your existing UT system credentials.  Use this portal to setup two factor authentication.  This is required to connect to the cluster and submit jobs/run commands.

TACC is accessible via terminal by logging in to TACC via ssh: `ssh [username]@ls6.tacc.utexas.edu`

# TACC Alphafold Setup Instructions

## Storage

The TACC system has 3 separate filesystems to be used for specific purposes.  Each user has their own folder created inside of each of these 3 filesystems and can be accessed using environment variables that are set when you login:

- `$HOME` - Your home directory - where you start when you're logged in.
- `$WORK` - To be used to store software you need to install to perform your work on TACC (e.g. alphafold and supporting programs)
- `$SCRATCH` - Used to store temporary files.  Never store important files in this directory - TACC periodically cleans out files that have not been accessed for at least 10 days.

For more information on each of these directories, check [TACC's documentation](https://portal.tacc.utexas.edu/user-guides/lonestar5#table-file-system-usage-recommendations)

In my alphafold setup, I have the following directories created in `$WORK`:
- `af_outputs/` - output files from all the Alphafold runs
- `alphafold_dbs/` - zipped files of databases needed to run Alphafold in
- `alphafold/` - Alphafold's source code

Here are the directories I have in my `$SCRATCH` directory:
- `alphafold_dbs/` - downloaded databases used by Alphafold during every run

## Setting up Alphafold

This process can be tedious and finicky.  I recommend that you are at least familiar with and have used `git` in the past and have at least some experience with running terminal commands before proceeding.

1. In your `$WORK` directory, clone the alphafold repository from my github page: `git clone https://github.com/davedingal/alphafold.git`
2. Checkout the `save_points` branch, then run the `setup.sh` script.  This script will install all necessary executables and python modules for alphafold to function.
3. Download all required databases by running the script `scripts/download_all_data.sh` with the following arguments: `$SCRATCH/alphafold_dbs/ $WORK/alphafold_dbs/`
  - This step will most likely take a couple of **days**.

The alphafold databases are very large.  Here is alist of all the databases and how large they are after decompressing:

```
$DOWNLOAD_DIR/                             # Total: ~ 2.2 TB (download: 438 GB)
    bfd/                                   # ~ 1.7 TB (download: 271.6 GB)
        # 6 files.
    mgnify/                                # ~ 64 GB (download: 32.9 GB)
        mgy_clusters_2018_12.fa
    params/                                # ~ 3.5 GB (download: 3.5 GB)
        # 5 CASP14 models,
        # 5 pTM models,
        # 5 AlphaFold-Multimer models,
        # LICENSE,
        # = 16 files.
    pdb70/                                 # ~ 56 GB (download: 19.5 GB)
        # 9 files.
    pdb_mmcif/                             # ~ 206 GB (download: 46 GB)
        mmcif_files/
            # About 180,000 .cif files.
        obsolete.dat
    pdb_seqres/                            # ~ 0.2 GB (download: 0.2 GB)
        pdb_seqres.txt
    small_bfd/                             # ~ 17 GB (download: 9.6 GB)
        bfd-first_non_consensus_sequences.fasta
    uniclust30/                            # ~ 86 GB (download: 24.9 GB)
        uniclust30_2018_08/
            # 13 files.
    uniprot/                               # ~ 98.3 GB (download: 49 GB)
        uniprot.fasta
    uniref90/                              # ~ 58 GB (download: 29.7 GB)
        uniref90.fasta
```

## Running alphafold

Alphafold requires a GPU to work efficiently.  TACC has several compute nodes that each have 2 NVIDIA A100 GPUs.  If you are familiar with `tmux`, I highly recommend using it to run your jobs.  This way you can safely detach from `tmux` and logout of TACC without killing your job.

To run a job, you must ask the cluster for a gpu node.  TACC uses `idev` for node allocation.  The following command should give you access to 1 GPU node for 1000 minutes:

`idev -p gpu-a100 -m 1000`

Once you have been allocated a gpu node, your command prompt will change reflecting the node you are now running commands on.

I have provided a convenient script to run alphafold called `run.sh` which requires 3 inputs:
- `--data_dir` - the path to the alphafold databases (set this to `$SCRATCH/alphafold_dbs/`)
- `--fasta_file` - the path to the fasta input file on which you want to run alphafold.  You can store these files `$HOME` since they are usually very small.
- `--output_dir` - the path to the directory that will contain alphafold's output (set this to `$WORK/af_outputs`)

For example, from `$WORK/alphafold`: `./run.sh --data_dir=$SCRATCH/alphafold_dbs/ --fasta_file=$HOME/test_protein.fasta --output_dir=$WORK/af_outputs`

TACC is usually able to run alphafold relatively quickly - the command should finish within 20 minutes.

## Reading the output

Alphafold's output is stored in whatever directory you passed to `--output_dir`.  That directory will contain a subdirectory with the same name as the fasta file you used as an input (for example, if you named your fasta file `test_protein.fasta` and `--output_dir` was set to `$WORK/af_outputs/`, the output will be stored in `$WORK/af_outputs/test_protein/`).  The most important files are the `.pdb` files along with a `.json` file containing scoring information about each predicted model that alphafold generated.  The output will also contain a bunch of `.pkl` or "pickle" files, which contain binary python object data such as the per-residue pLDDT confidence scores.
