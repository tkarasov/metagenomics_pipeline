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
#  Use /bin/bash to execute this scripti
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#

# -pe parallel 30
##  Reserve 30 CPUs for this job
#
#  Request 30G of RAM
## -l h_vmem=1G
#  Limit run time to 4 hours
## -l h_rt=4:00:00


sample=$1
read1=$2
read2=$3
read_direc=$4

echo "$sample"

mkdir -p $sample.logs
picard=/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/picard.jar
samtools=/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/samtools/samtools
seqstats=/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/seqstats/seqstats

# Running bwa mem to mapp short reads against TAIR10 ref genome
bwa mem\
    -R "@RG\tID:$sample\tSM:$sample"\
    /ebio/abt6_projects9/microbiome_analysis/data/genomes_DATA/athaliana/bwa_indexes/TAIR10 \
    $read1 $read2 2> $sample.logs/bwa.err |\
    /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/samtools/samtools view \
    -u -U "$sample"unmapped.bam -q 20 - |\
    /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/samtools/samtools sort -m 970m - > "$sample".bam 2> $sample.logs/samsort.err

#-u Output uncompressed BAM
#-U write items not selected by filter items to other file. This pushes the
#The following was removed -t 30 -@30 Number of BAM compression threads to use in addition to main thread
#-m 970m Only output alignments with number of CIGAR bases consuming query sequence ≥ INT [0]


printf "Finished alignment status: $?\n"


# Run picardtools to remove PCR and optical duplicates from alignment
# file
java -Xmx20g -jar \
    $picard \
    MarkDuplicates I="$sample".bam O="$sample"DEDUP.bam \
    M=$sample.logs/metrics.txt REMOVE_DUPLICATES=true 2> $sample.logs/picard.err

# Remove unduplicated file
printf "Finished duplicate removal status: $?\n"
rm "$sample".bam
mv "$sample"DEDUP.bam "$sample".bam

#calculate read depth (-a option outputs absolutely all positions). Last line of depth file is the average depth
$samtools depth -a  "$sample".bam > $sample.depth
cat $sample.depth| grep chr | cut -f 3 | awk '{ total += $1 } END { print total/NR }'>> $sample.depth

# Extract unmapped reads (-f 4 extracts only unmapped reads)
$samtools view \
    -u -f 4  "$sample"unmapped.bam |\
    $samtools fastq -|\
    paste - - - - |\
    sort -k1 -V |\
    /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/keep_paired.py \/ "$sample"MetagenomicR1R2.fq "$sample"S.fq

printf "Finished unmapped extraction status: $?\n"


gzip -9 "$sample"MetagenomicR1R2.fq &
gzip -9 "$sample"S.fq &
wait
$seqstats "$sample"MetagenomicR1R2.fq.gz > "$sample"Metagenomic.seqstats


