#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=6000
#SBATCH -t 2000

module load bowtie

~/Software/trinityrnaseq-2.2.0/Trinity  --genome_guided_bam ../RNAseq-data/$GENOME_NAME.alignment.sorted.bam --genome_guided_max_intron $MAX_INTRON_LENGTH --output trinity_TGG --CPU $LOCAL_CPUS --jaccard_clip --full_cleanup --max_memory 60G
