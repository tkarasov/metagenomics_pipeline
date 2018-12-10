#!/bin/bash
#  Reserve 4 CPUs for this job
#$ -pe parallel 6
#  Request 128G of RAM
#$ -l h_vmem=32G
#$ -cwd
#$ -e error_centrifuge_total.out
#$ -o output_centrifuge_total.out
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N metagenome.$1
#  Run job from current working directory
# Merge stdout and stderr. The job will create only one output file which
#  contains both the real output and the error messages.
#$ -j y
#  Use /bin/bash to execute this script
#$ -S /bin/bash


#usage qsub -v curr_direc=/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/ /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_pipeline.sh


#centrifuge pipeline instructions
#change to the directory of reads
curr_direc=/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections #$curr_direc
echo "This is the directory:"$curr_direc
python=/ebio/abt6_projects7/small_projects/tkarasov/Programs/miniconda3/bin/python

#any_metagenome_pipeline_centrifuge.sh
#1 Run bwa mem to remove plant reads
#run_plantRemoval_tlk_centrifuge.sh

#2 Take unmapped reads and classify with centrifuge
bash /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_db.sh $curr_direc
#3 once all classification is done, aggregate output from centrifuge and run process_centrifuge.
# The metagenomic_report file has a list of all of the centrifuge output reports
ls $curr_direc/centrifuge_output/*R1.fq.report > $curr_direc/centrifuge_output/metagenomic_report.txt
$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/process_centrifuge.py


#4 Feed output from #3 into recalibrate which outputs normalized data file
$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/recalibrate_metagenome_table_centrifuge.py -meta $curr_direc/centrifuge_output/centrifuge_metagenome_table.txt -host $curr_direc


#5 Graph output from #4
$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/visualize_metagenomes.py
