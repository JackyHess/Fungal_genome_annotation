#!/bin/bash

#SBATCH --cpus-per-task=1
#SBATCH --account=uio
#SBATCH --mem-per-cpu=2000
#SBATCH -t 200


$JAMG_PATH/3rd_party/bin/fathom $GENOME_NAME.ann $GENOME_NAME.dna -gene-stats | tee gene.statistics.log

$JAMG_PATH/3rd_party/bin/fathom $GENOME_NAME.ann $GENOME_NAME.dna -categorize 1000

$JAMG_PATH/3rd_party/bin/fathom -export 1000 -plus uni.ann uni.dna

$JAMG_PATH/3rd_party/snap/forge export.ann export.dna

$JAMG_PATH/3rd_party/snap/hmm-assembler.pl $GENOME_NAME . > $GENOME_NAME.hmm
