#! /usr/bin/env python

# prefilter the big agaricomycete dataset to include only the best five matches for each locus
# in order to save computational time during the gene prediction pipeline

from subprocess import *
from Bio import SeqIO

import os

#import utils.SLURM as slurm


def rename_fasta_headers(inp_file, outfile):

    fp_in = open(inp_file, "r")
    seqs = list(SeqIO.parse(fp_in, "fasta"))
    fp_in.close()

    fp_out = open(outfile, "w")
    new_ids = []
    for seq in seqs:
        if len(seq.id.split("|")) > 1:
            if not seq.id.split("|")[1]+"_"+seq.id.split("|")[2] in new_ids:
                fp_out.write(">"+seq.id.split("|")[1]+"_"+seq.id.split("|")[2]+"\n")
                fp_out.write(str(seq.seq)+"\n")
                new_ids.append(seq.id.split("|")[1]+"_"+seq.id.split("|")[2])
    fp_out.close()

def split_input_file(input_file, output_dir):

    fp_in = open(input_file, "r")
    seqs = list(SeqIO.parse(fp_in, "fasta"))
    fp_in.close()

    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    contig_counter = 0
    cnt = 1
    chunk_queue = []
    # write output files, single contig if larger than 50,000, multiple file up to that size  
    for seq in seqs:
        # > 50,000
        if len(seq.seq) >= 50000:
            new_chunk = "chunk_"+str(cnt)+".fa"
            if chunk_queue == []:
                fp_out = open(output_dir+new_chunk,"w")
                SeqIO.write([seq],fp_out, "fasta")
                fp_out.close()
                cnt += 1
            else:
                fp_out = open(output_dir+new_chunk,"w")
                SeqIO.write(chunk_queue,fp_out, "fasta")
                fp_out.close()
                contig_counter = 0
                chunk_queue = []
                cnt += 1
                new_chunk = "chunk_"+str(cnt)+".fa"
                fp_out = open(output_dir+new_chunk,"w")
                SeqIO.write([seq],fp_out, "fasta")
                fp_out.close()
                cnt += 1
        else:
            if chunk_queue == []:
                chunk_queue.append(seq)
                contig_counter += len(seq.seq)
            else:
                chunk_queue.append(seq)
                contig_counter += len(seq.seq)
                if contig_counter >= 50000:
                    new_chunk = "chunk_"+str(cnt)+".fa"
                    fp_out = open(output_dir+new_chunk,"w")
                    SeqIO.write(chunk_queue,fp_out, "fasta")
                    fp_out.close()
                    contig_counter = 0
                    chunk_queue = []
                    cnt += 1
                else:
                    chunk_queue.append(seq)
                    contig_counter += len(seq.seq)

def write_batch_script(outfile, cmd):

    fp_out = open(outfile,"w")
    fp_out.write("#!/bin/bash\n\n")
    fp_out.write("#SBATCH --cpus-per-task=8\n")
    fp_out.write("#SBATCH -t 3000\n")
    fp_out.write("#SBATCH --account=uio\n")
    fp_out.write("#SBATCH --mem-per-cpu=1500\n\n")
    fp_out.write(cmd+"\n")
    fp_out.close()

def monitor_job_list(job_list, interval, max_len=0):

    import time

    while len(job_list) > int(max_len):
        time.sleep(int(interval))
        for job_id in job_list:
            try:
                cmd = "sacct -j "+job_id
                output = Popen(cmd,stdout=PIPE,shell=True)
                status = output.stdout.readlines()[2].split()[5]

                if status == "RUNNING":
                    pass
                elif status == "PENDING":
                    pass
                elif status == "COMPLETING":
                    pass
                elif status == "SUSPENDED":
                    pass
                else:
                    job_list.remove(job_id)
                    if status != "COMPLETED":
                            print "Exited with status: "+status
            except:
                print "something went wrong!"
                job_list.remove(job_id)
    
    return 1
        


def run_blast(input_dir, agaricodb, outfile):

    input_files = os.listdir(input_dir)

    job_ids = []

    for fasta_file in input_files:
        if fasta_file.endswith(".fa"):
            cmd = "blastx -db "+agaricodb+" -query "+input_dir+fasta_file+" -out "+input_dir+fasta_file.strip(".fa")+".blast_out"+" -evalue 10e-5 -culling_limit 5 -outfmt 6 -num_threads 8"
            if not os.path.exists(input_dir+fasta_file.strip(".fa")+".blast_out"):
                while len(job_ids) > 200:
                    monitor_job_list(job_ids, 120)
                write_batch_script(input_dir+fasta_file+"_blastp.sh", cmd)
                output = Popen("sbatch "+input_dir+fasta_file+"_blastp.sh",stdout=PIPE,shell=True)
                job_id = output.stdout.readline().split()[-1].strip("\n")
                job_ids.append(job_id)

    monitor_job_list(job_ids, 0)
    filenames = []

    for ofile in os.listdir(input_dir):
        if ofile.endswith(".blast_out"):
            filenames.append(input_dir+ofile)

    with open(outfile, 'w') as fp_out:
        for fname in filenames:
            with open(fname) as infile:
                fp_out.write(infile.read())
    


def parse_blast_subset_fasta(protein_fasta, blast_out, target_protein_fasta):

    # parse prot ids from blast output and generate a subsetted fasta file for MAKER

    fp_in = open(blast_out, "r")
    line = fp_in.readline()

    parsed_ids = []

    ## while line:
    ##     if line.startswith(">"):
    ##         new_id = line.strip().split()[1]
    ##     new_id = line.split("\t")[1]
    ##         if not new_id in parsed_ids:
    ##             parsed_ids.append(new_id)
    ##     line = fp_in.readline()

    while line:
        new_id = line.split()[1]
        if not new_id in parsed_ids:
            parsed_ids.append(new_id)
        line = fp_in.readline()
         

    fp_in.close()

    # parse fasta and make new file

    fp_seq = open(protein_fasta, "r")
    seqs = SeqIO.to_dict(SeqIO.parse(fp_seq, "fasta"))

    new_seqs = []
    for sid in parsed_ids:
        try:
            new_seqs.append(seqs[sid])
        except KeyError:
            print "your BLAST DB and FASTA identifiers do not match up"

    fp_seq.close()

    fp_out = open(target_protein_fasta, "w")
    SeqIO.write(new_seqs, fp_out, "fasta")
    fp_out.close()

def run_subsetting(genome_fasta, protein_fasta, agarico_db, outfasta, tempdir):

    # split up genome file into small parts
    split_input_file(genome_fasta, tempdir)

    # run blast search
    run_blast(tempdir, agarico_db, "blast_results.out")

    #parse and collect
    parse_blast_subset_fasta(protein_fasta, "blast_results.out", outfasta)


def remove_species_from_set(protein_set, species_tag, outfile):

    # read BLAST

    fp_in = open(protein_set, "r")
    seqs = list(SeqIO.parse(fp_in, "fasta"))
    fp_in.close()

    # filter
    new_seqs = []
    for seq in seqs:
        if seq.id.split("_")[0] != species_tag:
            new_seqs.append(seq)

    # write
    fp_out = open(outfile, "w")
    SeqIO.write(new_seqs, fp_out, "fasta")
    fp_out.close()



if __name__ == '__main__':

    import sys

    if len(sys.argv) == 6:
        run_subsetting(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    elif len(sys.argv) == 4:
        parse_blast_subset_fasta(sys.argv[1], sys.argv[2], sys.argv[3])
        #remove_species_from_set(sys.argv[1], sys.argv[2], sys.argv[3])
    elif len(sys.argv) == 3:
        rename_fasta_headers(sys.argv[1], sys.argv[2])
    else:
        print "run_subsetting(genome_fasta, protein_fasta, agarico_db, outfasta, tempdir)"
        print "parse_blast_subset_fasta(protein_fasta, blast_out, target_protein_fasta)"
        print "rename_fasta_headers(inp_file, outfile)"
        print "remove_species_from_set(protein_set, species_tag, outfile)"
