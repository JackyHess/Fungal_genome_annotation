#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=3000
#SBATCH -t 1500

module load samtools

module load hisat2

hisat2-build $GENOME_PATH $GENOME_NAME

hisat2 --dta --min-intronlen 20 --max-intronlen $MAX_INTRON_LENGTH -p $LOCAL_CPUS $GENOME_NAME -1 ../../RNASeq-data/read1_trimmed_paired.fastq -2 ../../RNASeq-data/read2_trimmed_paired.fastq -U ../../RNASeq-data/single_end_trimmed.fastq | samtools view -Shb - | samtools sort - $GENOME_NAME.alignment.sorted.bam
