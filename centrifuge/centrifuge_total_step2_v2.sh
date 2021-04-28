#!/bin/bash
#
#$ -N make_kreport
#  Request 16G of RAM
#$ -l h_vmem=16G
#$ -S /bin/bash
# $ -t 1-650
#$ -o $JOB_NAME_$TASK_ID.out
#$ -e $JOB_NAME_$TASK_ID.err

# usage qsub -v curr_direc=/ebio/abt6_projects9/pathodopsis_microbiomes/data/processed_reads/metagenome/run116_2018_9_metagenome_reads/ -t <num_jobs> /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_step2_v2.sh

#this script takes the output from centrifuge and makes kreports of everything

#########################################################################
## Setting variables
#########################################################################
curr_direc=$curr_direc
cd $curr_direc
echo "This is the directory:"$curr_direc
#ls $curr_direc/centrifuge_output/*R1.fq.report > $curr_direc/centrifuge_output/metagenomic_report.txt

#########################################################################
## Make an array of the centrifuge report names
#########################################################################
#INPUTFILES=($(cat $curr_direc/centrifuge_output/metagenomic_out.txt))
INPUTFILES=($(cat $curr_direc/centrifuge_output/metagenomic_out.txt))

# Pull data file name from list defined above according to job id
INPUTFILENAME="${INPUTFILES[$SGE_TASK_ID - 1]}"
#INFILE=`awk "NR==$SGE_TASK_ID" $curr_direc/centrifuge_output/metagenomic_report.txt`
#########################################################################
## Generate a kraken-style report for every centrifuge report
#########################################################################
/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge-kreport -x \
/ebio/abt6_projects9/metagenomic_controlled/database/nt $INPUTFILENAME > $INPUTFILENAME.kreport

echo "$INPUTFILENAME"
