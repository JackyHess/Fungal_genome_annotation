# Fungal_genome_annotation
General and specific recipes used for genome annotation of different fungal genomes

Use JamG pipeline for annotation of fungal genomes http://jamg.sourceforge.net/ 

Software prerequisites:

* JamG https://github.com/genomecuration/JAMg
* Trinity https://github.com/trinityrnaseq/trinityrnaseq/wiki
* Hisat2 https://ccb.jhu.edu/software/hisat2/index.shtml
* BRAKER1 http://exon.gatech.edu/GeneMark/braker1.html
* CodingQuarry  https://sourceforge.net/projects/codingquarry/

Data required:

* Genome assembly
* RNA-seq data (quality filtered and adapters removed)

Step-by-step instructions

##  1) Set up project, prepare data and repeat mask the assembly

Make a new directory for the focus species, create a new environmental variable file from [env_SPECIES_template.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/env_SPECIES_example.sh) and edit accoding to your requirements.

**Collect RNA-seq data**

`mkdir RNAseq-data`

Copy or link RNA-seq datasets into this directory. For Trinity, create a forward and reverse read dataset (paired end and single end reads can be combined by appending the single end reads to the forward reads).

`mkdir forward_reads; mkdir reverse_reads`

Recode reads to FASTA and assure that forward read names end with /1 and reverse reads with /2

PE data:

`fastool --to-fasta  --append /1 forward_reads/read1_trimmed_paired.fastq > forward_reads/read1_trimmed_paired.fasta`

`fastool --to-fasta  --append /2 forward_reads/read2_trimmed_paired.fastq > forward_reads/read2_trimmed_paired.fasta`

SE data:

`fastool --to-fasta  --append /1 forward_reads/single_end_trimmed.fastq > forward_reads/single_end_trimmed.fasta`

Prepend with zcat and pipe if files are gzipped.

**Align RNA-seq data to the genome**

Align RNA-seq data using Hisat2

Create, adapt and run job script for alignment from [run_hisat.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_hisat.sh)

**Repeat masking**

`mkdir exon_search; cd exon_search`

Create, adapt and run job script for masking from [run_repeat_mask.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_repeat_mask.sh)


## 2) Assemble transcriptome

**Trinity _de novo_**

`mdkir trinity_assemblies; cd trinity_assemblies`

Create, adapt and run job script for _de novo_ assembly from [run_trinity_denovo.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_trinity_denovo.sh)

**Genome-guided Trinity**

Create, adapt and run job script for genome-guided assembly from [run_genomeguided_trinity.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_genomeguided_trinity.sh)

Combine Trinity output and prepare for PASA

`$JAMG_PATH/3rd_party/PASA/misc_utilities/accession_extractor.pl < trinity_TDN.Trinity.fasta > tdn.accs`

`cat trinity_TDN.Trinity.fasta trinity_TGG/Trinity-GG.fasta > transcripts.fasta`

Clean transcripts

Create, adapt and run job script for seqclean from [run_seqclean.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_seqclean.sh)

## 3) PASA transcriptome reconstruction

PASA analysis happens on my Virtual Box instance on my local computer (due to MySQL requirement). To run it, I transfer “transcripts.fasta”, “transcripts.fasta.clean”, “transcripts.fasta.cln”, “tdn.accs” from the “trinity_assemblies” directory and the genome FASTA file to a new folder on my Virtual Box.

Create new config file from [alignAssembly_template.config](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/alignAssembly_template.config). The most important parameter is the MYSQLDB database name.

**Run PASA**

`/home/jacky/Software/PASApipeline-2.0.1/scripts/Launch_PASA_pipeline.pl -c alignAssembly.config -C -R -g genome.fasta --MAX_INTRON_LENGTH 300 --ALIGNERS blat,gmap --TRANSDECODER --CPU 1 -T -t transcripts.fasta.clean -u transcripts.fasta --TDN tdn.accs --stringent_alignment_overlap 30.0 |& tee pasa.log
`

`--stringent_alignment_overlap` is added for gene dense genomes to avoid overclustering of transcripts with overlapping UTRs

This step takes quite a while on a single CPU, but if it crashes or has to be interrupted, the analysis can be restarted by removing the parameter `-C` and adding `-s x` where `x` is the number of the last succesfully completed step. If in doubt choose `-s 1`.

Build comprehensive transcriptome

`/home/jacky/Software/PASApipeline-2.0.1/scripts/build_comprehensive_transcriptome.dbi -c pasa.alignAssembly.Template.txt -t transcripts.fasta.clean`

Create golden gene set for training gene predictors (mainly SNAP at this point)

`/home/jacky/Software/PASApipeline-2.0.1/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta ./*.assemblies.fasta --pasa_transcripts_gff3 ./*.pasa_assemblies.gff3`

**Copy relevant PASA files to cluster directory**

`mkdir PASA; cd PASA`

Move the files `*.assemblies.fasta`, `*.assemblies.fasta.transdecoder.cds`, `*.assemblies.fasta.transdecoder.genome.gff3`, `*.assemblies.fasta.transdecoder.gff3`, `*.assemblies.fasta.transdecoder.pep`, `*.pasa_assemblies.gff3` back to the cluster

Extract golden genes

Create, adapt and run job script for extracting training set [extract_golden_genes.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/extract_golden_genes.sh)

## 4) Run gene predictors

`mkdir gene_predictors; cd gene_predictors`

**BRAKER**

`mkdir braker; cd braker`

Run BRAKER using the Hisat2 alignment as input. Create, adapt and run job script for BRAKER from [run_braker.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_braker.sh)

**CodingQuarry**

`mkdir coding_quarry; cd coding_quarry`

Create, adapt and run job scripts for CodingQuarry [run_coding_quarry.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_coding_quarry.sh)

**SNAP**

`mkdir snap; cd snap`

`mkdir train; cd train`

`cp ../../../PASA/final_golden_genes.gff3.nr.golden.train.zff $GENOME_NAME.ann`

Follow suggestions and use scripts from [https://biowize.wordpress.com/2012/06/01/training-the-snap-ab-initio-gene-predictor/](https://biowize.wordpress.com/2012/06/01/training-the-snap-ab-initio-gene-predictor/) to generate well formed training set. 

`grep '^>' $GENOME_NAME.ann | tr -d '>' > $GENOME_NAME.seqs2keep`

`perl /usit/abel/u1/jacqueh/Software/jamg/3rd_party/snap/fasta_sort.pl $GENOME_NAME.seqs2keep < $GENOME_PATH > $GENOME_NAME.dna`

Validate gene models and remove invalid models if necessary. I remove those that result in an internal stop codon, but keep those with warnings about alternative splice acceptor/donor sites or microexons.

`/usit/abel/u1/jacqueh/Software/jamg/3rd_party/snap/fathom $GENOME_NAME.ann $GENOME_NAME.dna -validate > validate.res`

Repeat FASTA sorting to remove scaffolds with no genes on them (if genes were removed from the training set)

`grep '^>' $GENOME_NAME.ann | tr -d '>' > $GENOME_NAME.seqs2keep`

`perl /usit/abel/u1/jacqueh/Software/jamg/3rd_party/snap/fasta_sort.pl $GENOME_NAME.seqs2keep < $GENOME_PATH > $GENOME_NAME.dna`


Run training round

Create, adapt and run job script for training SNAP [train_snap.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/train_snap.sh)

Use model to predict

`cd ../ ; mkdir predict; cd predict`

`ln -s $GENOME_PATH.softmasked $GENOME_NAME.softmasked`

Create, adapt and run job script for SNAP [run_snap.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_snap.sh)

## 5) Generate external evidence for EvidenceModeler

Besides the transcript data we derive from PASA alignments, we are also using protein homology information to inform the validity of predicted gene structures. 

For this, I use protein data downloaded from JGI (e.g. all Agaricomycete predicted proteins) and rarify those using CD hit like so:

`mkdir foreign; cd foreign`

Download database to directory

`gunzip *.gz`

`cat *.aa.fasta > all_reference_proteins.fasta`

`cd-hit -c 0.90 -i all_reference_proteins.fasta -o all_reference_proteins.fasta.nr90 -d 0 -M 0 -T 4`

**AAT alignments**

Filter the Agaricomycete protein set to only retain 5 matches per locus (makes the alignment faste).

Create, adapt and run job script for BLASTX [extract_best_hits.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/extract_best_hits.sh)

This will take quite a while...

Create, adapt and run job script for AAT [run_AAT.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_AAT.sh)

## 6) Evaluate gene predictor output and external evidence and run EvidenceModeler

Before running EvidenceModeler and combining it all, I try to get a feeling for how well the gene predictors are performing, whether to rerun any training steps, or if I'm happy enough how the evidence from each should be weighed. 

I don't have a great quantitative way of deciding on this, but I find that the most common errors are spottable by eye. Things I look out for in particular for fungal genomes are fusion genes, where multiple transcripts are spliced together, and fragmentation of predicted gene models. 

To do this, I use IGV https://www.broadinstitute.org/igv/

`mkdir evidencemodeler; cd evidencemodeler`

Collect all input for EvidenceModeler

`cp ../PASA/*.pasa_assemblies.gff3 transcript_alignments.gff3`

`cat ../gene_predictors/braker/genemark.gff3 ../gene_predictors/braker/augustus_EVM.gff3 ../gene_predictors/coding_quarry/coding_quarry.gff3 ../gene_predictors/snap/predict/snap.gff3 > abinitio_gene_predictions.gff3`

`cat ../PASA/*.assemblies.fasta.transdecoder.genome.gff3 >> abinitio_gene_predictions.gff3`

`cp ../foreign/$GENOME_NAME.best_matches_agaricomycetes.gff3 protein_alignments.gff3`

Generate new weights file

`cp $JAMG_PATH/configs/evm_weights.txt .` See [here](https://github.com/JackyHess/Fungal_genome_annotation/edit/master/evm_weights.txt) for an example. It's important here that the evidence descriptor (i.e. name of the program) exactly matches column 2 in the respective GFF3 files produced by each gene predictor.

Create, adapt and run job script for EvidenceModeler [run_evidencemodeler.sh](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/run_evidencemodeler.sh)

## 7) Clean up the annotations using PASA

Create new PASA config file for annotation comparison [pasa.AnnotCompare.cfg](https://github.com/JackyHess/Fungal_genome_annotation/blob/master/pasa.AnnotCompare.cfg)

PASA usually needs to run for at least two rounds in order to be able to incorporate all transcripts successfully. 

Copy `$GENOME_NAME.evm.gff3` to the virtual machine.

Run PASA annotation comparison

`/home/jacky/Software/PASApipeline/scripts/Launch_PASA_pipeline.pl -c pasa.AnnotCompare.cfg -g $GENOME_PATH -t transcripts.fasta.clean -A -L --annots_gff3 *.evm.gff3`

Run a second time (plug in the output file from the previous run here)

`/home/jacky/Software/PASApipeline/scripts/Launch_PASA_pipeline.pl -c pasa.AnnotCompare.cfg -g $GENOME_PATH -t transcripts.fasta.clean -A -L --annots_gff3 *.gene_structures_post_PASA_updates.<number_index>.gff3`

Clean up annotation file, make gene IDs and generate common accompanying files

`mkdir final_annotation; cd final_annotation`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_file_simple_acc_resetter.pl  ../*.gene_structures_post_PASA_updates.<final_number_index>.gff3 $GENOME_PATH > $GENOME_NAME.final_annotation.gff3`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_file_to_proteins.pl $GENOME_NAME.final_annotation.gff3 $GENOME_PATH > $GENOME_NAME.final_annotation.proteins.fasta`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_file_promoter_extractor.pl --genes $GENOME_NAME.final_annotation.gff3 --genome $GENOME_PATH > $GENOME_NAME.final_annotation.promoters.fasta`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_file_to_proteins.pl $GENOME_NAME.final_annotation.gff3 $GENOME_PATH CDS > $GENOME_NAME.final_annotation.CDS.fasta`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_file_to_proteins.pl $GENOME_NAME.final_annotation.gff3 $GENOME_PATH cDNA > $GENOME_NAME.final_annotation.transcripts.fasta`

`/home/jacky/Software/PASApipeline/misc_utilities/gff3_to_gtf_format.pl $GENOME_NAME.final_annotation.gff3 $GENOME_PATH > $GENOME_NAME.final_annotation.gtf`

Done!
