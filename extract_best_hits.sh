#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=500
#SBATCH -t 500

makeblastdb -in all_reference_proteins.fasta.nr90 -dbtype prot -out all_reference_proteins.fasta.nr90

python /usit/abel/u1/jacqueh/Code/GenomeAnnotation/filter_agaricomycete_protein_set.py $GENOME_PATH all_reference_proteins.fasta.nr90 all_reference_proteins.fasta.nr90 best_matches_agaricomycetes.fa tmp_blast/
