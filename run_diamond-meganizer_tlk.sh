#!/bin/sh
#
#
#
#####################################################################
# "meganize" daa file, perform taxonomic binning of aligned reads
#  and reformat file so that it can be analized with megan
# Usage: 
#       bash run_diamond-meganizer.sh <samplename>.daa
# or:
#       qsub -N <samplename> -o meganizer.out -e meganizer.err run_diamond-meganizer.sh <samplename>.daa
# 
# where:
#       samplename       = "Name of the sample to process, this string
#                           will be used as basename for the output file
#       samplename.daa   = "daa file with aligned reads"
#
####################################################################
#  Import environment
#$ -V
#  Reserve 20 CPUs for this job
## -pe parallel 20
#
#  Request 40G of RAM 
## -l h_vmem=2G
#  Limit run time to 1 hour for short queue
## -l h_rt=1:00:00
#
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#
#  Send email when the job aborts or is suspended
#$ -m as

in=$1

/ebio/abt6_projects9/metagenomic_controlled/Programs/megan/tools/daa-meganizer\
    -i "$in"\
    -v\
    -sup 1000\
    -a2t /ebio/abt6_projects9/microbiome_analysis/data/software/megan6/data/prot_acc2tax-Oct2017X1.abin\
    -a2kegg /ebio/abt6_projects9/microbiome_analysis/data/software/megan6/data/acc2kegg-Dec2017X1-ue.abin


#annotated: sup command=, v is verbose
