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




