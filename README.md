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
* RNA-seq data

Step-by-step instructions

1) Set up project, prepare data and repeat mask the assembly

Make a new directory for the focus species, create a new environmental variable file from env_SPECIES_template.sh and edit accoding to your requirements.
