#!/bin/bash

#SBATCH -n 10
#SBATCH --ntasks-per-node=10
#SBATCH --account=uio
#SBATCH -t 1000
#SBATCH --mem-per-cpu=4000

gmap_build -d $GENOME_NAME $GENOME_PATH

gmap -D ~/databases/gmap -d $GENOME_NAME -B 5 --intronlength=$MAX_INTRON_LENGTH -f gff3_gene -t 10 ../../trinity_assemblies/transcripts.fasta.clean > all_transcripts.gff3

CodingQuarry -f $GENOME_PATH -t all_transcripts.gff3 -p 10 -d

# Convert output for EvidenceModeler
python /usit/abel/u1/jacqueh/Software/jamg/bin/CodingQuarry_to_GFF3.py out/PredictedPass.gff3 coding_quarry.gff3
