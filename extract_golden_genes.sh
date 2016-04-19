#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=500
#SBATCH -t 500

module load emboss

$JAMG_PATH/bin/prepare_golden_genes_for_predictors.pl -genome $GENOME_PATH.masked -softmasked $GENOME_PATH.softmasked -same_species -intron $MAX_INTRON_LENGTH -cpu $LOCAL_CPUS -norefine -complete -no_single -pasa_gff ./*.assemblies.fasta.transdecoder.gff3 -pasa_peptides ./*.assemblies.fasta.transdecoder.pep -pasa_cds ./*.assemblies.fasta.transdecoder.cds -pasa_genome ./*.assemblies.fasta.transdecoder.genome.gff3 -pasa_assembly ./*.assemblies.fasta
