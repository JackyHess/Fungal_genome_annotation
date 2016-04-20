
#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --account=uio
#SBATCH --mem-per-cpu=3000
#SBATCH -t 200

module load cufflinks #for gffread utility

$JAMG_PATH/bin/splitfasta.pl -i $GENOME_NAME.softmasked

find $GENOME_NAME.softmasked_dir1 -maxdepth 1 -type f -exec sh -c 'echo "$JAMG_PATH/3rd_party/snap/snap ../$GENOME_NAME.hmm $1 -lcmask -quiet > $1.snap 2>$

ParaFly -c snap.commands -CPU $LOCAL_CPUS -v –shuffle

cat $GENOME_NAME.softmasked_dir1/*snap.gtf > snap.gtf

gffread ../../../PASA/final_golden_genes.gff3.nr.golden.test.gff3 -T -o final_golden_genes.gff3.nr.golden.test.gtf

$JAMG_PATH/3rd_party/eval-2.2.8/evaluate_gtf.pl -g final_golden_genes.gff3.nr.golden.test.gtf snap.gtf > snap.eval
