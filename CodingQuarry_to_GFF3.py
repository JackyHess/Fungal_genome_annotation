#!/bin/env/python

# Modify the GFF3 output of CodingQuarry to match the input requirements of EvidenceModeler
# Specifically: add an mRNA feature for each gene and change the CDS parent to the mRNA ID.
# Also add exon feature

import argparse

#set up command line
parser = argparse.ArgumentParser()
parser.add_argument("coding_quarry_input", help="Coding Quarry output")
parser.add_argument("output", help="GFF3 output")

args = parser.parse_args()

#read in GFF file
gene_store = {}
gene_line = {}

fp_in = open(args.coding_quarry_input, "r")
line = fp_in.readline()
while line:
    elmts = line.strip().split()
    if elmts[2] == "gene":
        gene_id = elmts[8].split(";")[0].split("=")[-1]
        if gene_store.has_key(gene_id):
            print "Error, two genes with the same ID: ",gene_id
        else:
            # save CDS / exons for each gene in list
            gene_store[gene_id] = []
            gene_line[gene_id] = elmts
    elif elmts[2] == "CDS":
        parent = elmts[8].split(";")[1].split("=")[-1]
        gene_store[parent].append(elmts)
    else:
        print "Unknown feature: ",elmts[2]
    line = fp_in.readline()
fp_in.close()

fp_out = open(args.output,"w")
# for each gene ID, print gene line, then mRNA line, followed by CDS and exon with mRNA ID as parent
for gene_id in gene_store.keys():
    fp_out.write("\t".join(gene_line[gene_id])+"\n")
    mrna_ID = "m."+gene_id
    fp_out.write("\t".join(gene_line[gene_id][0:2])+"\tmRNA\t"+"\t".join(gene_line[gene_id][3:8])+"\tID="+mrna_ID+";Parent="+gene_id+";\n")
    exon_index = 1
    for cds in gene_store[gene_id]:
        cds_id = cds[8].split(";")[0].split("=")[-1]
        fp_out.write("\t".join(cds[0:8])+"\tID="+cds_id+";Parent="+mrna_ID+";\n")
        #write exon entry
        exon_id = "e"+str(exon_index)+":"+cds_id.split(":")[1] 
        fp_out.write("\t".join(cds[0:2])+"\texon\t"+"\t".join(cds[3:7])+"\t.\tID="+exon_id+";Parent="+mrna_ID+";\n")
        exon_index += 1
fp_out.close()
        
