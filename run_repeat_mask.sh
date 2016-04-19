#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=6000
#SBATCH --account=uio
#SBATCH -t 4000

module load emboss

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAMG_PATH/3rd_party/transdecoder/util/lib64/

$JAMG_PATH/bin/prepare_domain_exon_annotation.pl -verbose -genome $GENOME_PATH -repthreads $LOCAL_CPUS -engine local -mpi $LOCAL_CPUS -transposon_db /usit/abel/u1/jacqueh/Software/jamg/databases/hhblits/transposons -uniprot_db /usit/abel/u1/jacqueh/Software/jamg/databases/hhblits/uniprot20_2013_03

$JAMG_PATH/3rd_party/bin/maskFastaFromBed -soft -fi $GENOME_PATH -fo $GENOME_PATH.softmasked -bed *.out.gff
