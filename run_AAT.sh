#!/bin/bash

#SBATCH -n 1
#SBATCH -t 3000
#SBATCH --mem-per-cpu=16000
#SBATCH --account=uio

$JAMG_PATH/3rd_party/aatpackage/bin/AAT.pl -P -q $GENOME_PATH.masked --unmasked $GENOME_PATH -s best_matches_agaricomycetes.fa --dps ‘-f 100 -i 30 -a 200’ --filter ‘-c 10’ --nap ‘-x 5’

cat *best_matches_agaricomycetes.fa.nap.gff3 > $GENOME_NAME.best_hits_agaricomycetes.gff3
