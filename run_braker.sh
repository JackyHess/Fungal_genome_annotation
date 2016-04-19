#!/bin/bash

#SBATCH --account=uio
#SBATCH -t 2000
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=3200

braker.pl --overwrite --fungus --cores 16 --gff3 --genome=$GENOME_PATH.softmasked --species $GENOME_NAME.BRAK --bam=../../RNAseq-data/$GENOME_NAME.alignment.sorted.bam --AUGUSTUS_CONFIG_PATH=/usit/abel/u1/jacqueh/Software/augustus-3.2.1/config --GENEMARK_PATH=/usit/abel/u1/jacqueh/Software/gm_et_linux_64/gmes_petap --BAMTOOLS_PATH=/usit/abel/u1/jacqueh/Software/bamtools/bin --SAMTOOLS_PATH=/cluster/software/VERSIONS/samtools/1.2/bin --softmasking on --useexisting
