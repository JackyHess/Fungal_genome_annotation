#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=500
#SBATCH -t 2000

$JAMG_PATH/3rd_party/bin/seqclean transcripts.fasta -c $LOCAL_CPUS -n 10000
