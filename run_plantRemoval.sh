#!/bin/bash
#
#
#
#####################################################################
# Run map short read sequences to the Arabidopsis thaliana TAIR10
# reference genome
#
# Usage: bash run_plantRemoval.sh <samplename> <read1.fq> <read2.fq>
# or:
#       qsub -N samplename -o plantRemoval.out -e plantRemoval.err run_plantRemoval.sh samplename read1.fq read.fq
# where:
#       samplename = "Name of the sample to process, this string
#                     will be used as the read group in the bamfile"
#       read1.fq   = "path to file with first pairs of sequencing"
#       read2.fq   = "path to file with seconf pairs of sequencing"
#
#
####################################################################
#
#  Import environment
#$ -V 
#  Reserve 30 CPUs for this job
#$ -pe parallel 30
# 
#  Request 30G of RAM   
#$ -l h_vmem=1G
#  Limit run time to 4 hours
#$ -l h_rt=4:00:00
#
#  Use /bin/bash to execute this scripti
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#
#  Send email when the job aborts, or is suspended
#$ -m as

sample=$1
read1=$2
read2=$3
echo "$sample"
mkdir -p logs 


# Running bwa mem to mapp short reads against TAIR10 ref genome 
bwa mem\
    -t 30 -R "@RG\tID:$sample\tSM:$sample"\
    /ebio/abt6_projects9/microbiome_analysis/data/genomes_DATA/athaliana/bwa_indexes/TAIR10 \
    $read1 $read2 2> logs/bwa.err |\
    samtools view \
    -u -U "$sample"unmapped.bam -q 20 - |\
    samtools sort -@30 -m 970m - > "$sample".bam 2> logs/samsort.err

printf "Finished alignment status: $?\n"


# Run picardtools to remove PCR and optical duplicates from alignment
# file
java -Xmx20g -jar \
    $picard \
    MarkDuplicates I="$sample".bam O="$sample"DEDUP.bam \
    M=logs/metrics.txt REMOVE_DUPLICATES=true 2> logs/picard.err


# Remove unduplicated file
printf "Finished duplicate removal status: $?\n"
rm "$sample".bam
mv "$sample"DEDUP.bam "$sample".bam

# Extract unmapped reads
samtools view \
    -u -f 4  "$sample"unmapped.bam |\
    samtools fastq -|\
    paste - - - - |\
    sort -k1 -V |\
    /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/keep_paired.py \/ "$sample"MetagenomicR1R2.fq "$sample"S.fq

printf "Finished unmapped extraction status: $?\n"


gzip -9 "$sample"MetagenomicR1R2.fq & 
gzip -9 "$sample"S.fq &
wait
seqstats "$sample"MetagenomicR1R2.fq.gz > "$sample"Metagenomic.seqstats

touch finished
