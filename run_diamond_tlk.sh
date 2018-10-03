#!/bin/sh
#
#
#
#####################################################################
# Run short read mapping aganst NCBI NR database usin diamond,  
# the NR database currently being use is from 08/2017. Fairly up 
# to date
# Usage: 
#       bash run_diamond.sh <samplename> <reads.fq>
# or:
#       qsub -N <samplename> -o diamond.out -e diamond.err run_diamond.sh <samplename> <reads.fq>
# 
# where:
#       samplename = "Name of the sample to process, this string
#                     will be used as basename for the output file
#       reads.fq   = "path to file with reads to map aganst NR"
#
####################################################################
#  Import environment
#$ -V
#  Reserve 40 CPUs for this job
## -pe parallel 40
#
#  Request 150G of RAM 
## -l h_vmem=3.75G
#  Limit run time to 160 hour for short queue
#$ -l h_rt=160:00:00
#
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#
#  Send email when the aborts or is suspended
## -m as


sample=$1
input=$2

name=$(hostname)
#ln -s /ebio/abt6_projects9/microbiome_analysis/data/software/diamond-0.9.10/binNode444/diamond diamond
ln -s /ebio/abt6_projects9/microbiome_analysis/data/software/diamond/diamondOLD/diamond diamond
mkdir -p /tmp/tkarasov/"$sample"
./diamond blastx\
    -p 4\
    -d /ebio/abt6_projects9/abt6_databases/db/diamond/nr/nr_032018.dmnd\
    -o "$sample"\
    -f 100\
    -v\
    -q "$input"\
    -k 25\
    -b 10\
    -c 1\
    --log \
    --un "$sample"unaligned.fa\
    --unal 1\
    --tmpdir /tmp/tkarasov/"$sample"

if [ $? -eq 0 ]; then touch finishedDIAMOND;rm diamond; else touch ERROR_diamond;rm diamond;rm -r /tmp/tkarasov/"$sample";exit; fi
mv diamond.log logs
rm -r/tmp/tkarasov/"$sample"
gzip -9 "$sample"unaligned.fa

#--query (-q)           input query file
#--un file for unaligned queries
#--unal report unaligned queries (0=no, 1=yes)
#--index-chunks (-c)    number of chunks for index processing. The number of chunks for processing the seed index (default=4). This option can be additionally used to tune the performance. It is recommended to set this to 1 on a high memory server, which will increase performance and memory usage, but not the usage of temporary disk space.
#--max-target-seqs (-k) maximum number of target sequences to report alignments for
#--block-size (-b)      sequence block size in billions of letters (default=2.0
#--threads (-p)         number of CPU threads
#--outfmt (-f)          output format (what is 100?)


