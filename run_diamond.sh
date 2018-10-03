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
#$ -pe parallel 40
#
#  Request 150G of RAM 
#$ -l h_vmem=3.75G
#  Limit run time to 120 hour for short queue
#$ -l h_rt=120:00:00
#
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#
#  Send email when the aborts or is suspended
#$ -m as


sample=$1
input=$2

name=$(hostname)
ln -s /ebio/abt6_projects9/microbiome_analysis/data/software/diamond-0.9.10/binNode444/diamond diamond
mkdir -p /tmp/tkarasov/"$sample"
./diamond blastx\
    -p 40\
    -d /ebio/abt6_projects9/abt6_databases/db/diamond/nr/nr_082017.dmnd\
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
