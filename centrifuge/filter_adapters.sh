#!/bin/sh
#$ -N cutadapt_array_job
#$ -pe parallel 1
#$ -S /bin/bash
#$ -o $JOB_NAME.out
#$ -e $JOB_NAME.err
#$ -cwd
#$ -V


#reverse read
#CTGTCTCTTATACACATCTGACGCTGCCGACGAG
#cd /ebio/abt6_projects9/pathodopsis_microbiomes/data/processed_reads/metagenome/combine_runs/raw_filter
#cutadapt -a CTGTCTCTTATA  -o $INPUTFILENAME  /ebio/abt6_projects9/pathodopsis_microbiomes/data/processed_reads/metagenome/combine_runs/raw_concat/$INPUTFILENAME

cd $filter_read_dir
echo "raw reads are in " $raw_read_dir
echo "filtered reads are in " $filter_read_dir
echo "read 1 is:" $read1
echo "read 2 is:" $read2

temp1=`basename $read1`
temp2=`basename $read2`
read1=$temp1
read2=$temp2 
new_read1=`basename $read1`
new_read2=`basename $read2`
# read1=`ls | grep R1`

cutadapt -a CTGTCTCTTATA -A CTGTCTCTTATA --minimum-length 50 --pair-filter=any -o $filter_read_dir/$new_read1 -p $filter_read_dir/$new_read2 \
  $raw_read_dir/$read1 $raw_read_dir/$read2

