# set JamG installation directory
export JAMG_PATH=/usit/abel/u1/jacqueh/Software/jamg
# full path to the genome FASTA file
export GENOME_PATH=/projects/researchers/researchers01/jacqueh/Genome_annotation/SHA17-1/Sshas_SH17-1.fa
# genome name
export GENOME_NAME=Sshas_SHA17-1
# Number of available threads
export LOCAL_CPUS=10
# maximum available memory
export MAX_MEMORY_G=60
# Add JamG software to PATH
export PATH=$JAMG_PATH/bin:$JAMG_PATH/3rd_party/bin:$PATH
# Maximum intro length for focus species
export MAX_INTRON_LENGTH=300
