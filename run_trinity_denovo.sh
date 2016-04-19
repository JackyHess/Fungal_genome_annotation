#!/bin/bash

## Run Trinity De Novo

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=6000
#SBATCH -t 2000

module load bowtie

~/Software/trinityrnaseq-2.2.0/Trinity --bypass_java_version_check --seqType fa --left ../forward_read/read1_trimmed.fasta,single_end_trimmed.fa  --right ../reverse_reads/read2_trimmed_paired.fasta --output trinity_TDN --CPU $LOCAL_CPUS --jaccard_clip --full_cleanup --max_memory 60G
