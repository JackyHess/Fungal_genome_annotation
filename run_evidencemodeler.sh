#!/bin/bash

#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2000
#SBATCH --account=uio
#SBATCH -t 200

$JAMG_PATH/3rd_party/evidencemodeler/EvmUtils/partition_EVM_inputs.pl --genome $GENOME_PATH --gene_predictions abinitio_gene_predictions.gff3 --transcript_alignments transcript_alignments.gff3 --protein_alignments protein_alignments.gff3 --segmentSize 50000000 --overlapSize 10000 --partition_listing partitions_list.out --repeats $GENOME_PATH.out.gff

$JAMG_PATH/3rd_party/evidencemodeler/EvmUtils/write_EVM_commands.pl --genome $GENOME_PATH --weights `pwd`/evm_weights.txt --gene_predictions abinitio_gene_predictions.gff3 --transcript_alignments transcript_alignments.gff3 --protein_alignments protein_alignments.gff3 --output_file_name evm.out --partitions partitions_list.out --repeats $GENOME_PATH.out.gff > commands.list

$JAMG_PATH/3rd_party/bin/ParaFly -shuffle -v -CPU $LOCAL_CPUS -c commands.list -failed_cmds commands.list.failed

$JAMG_PATH/3rd_party/evidencemodeler/EvmUtils/recombine_EVM_partial_outputs.pl --partitions partitions_list.out --output_file_name evm.out

$JAMG_PATH/3rd_party/evidencemodeler/EvmUtils/convert_EVM_outputs_to_GFF3.pl  --partitions partitions_list.out --output evm.out --genome $GENOME_PATH

find . -name evm.out.gff3 -exec cat '{}' \; >> $GENOME_NAME.evm.gff3
