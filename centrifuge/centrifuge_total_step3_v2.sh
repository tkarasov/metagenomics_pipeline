#!/bin/bash
#
#  Reserve 4 CPUs for this job
#$ -pe parallel 4
#  Reserve 32 CPUs for this job
#$ -l h_vmem=16G
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N recalibrating.$1
#  Run job from current working directory
# Merge stdout and stderr. The job will create only one output file which
# contains both the real output and the error messages.
#$ -e error_centrifuge_total.out
#$ -o output_centrifuge_total.out
#$ -j y
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#

# usage qsub -v curr_direc=/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/ /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_pipeline.sh

#This script takes the output from the kraken kreports and processes them to be recalibrated

#########################################################################
## Set Directory
#########################################################################
#change to the directory of reads
curr_direc=$curr_direc
cd $curr_direc
echo "This is the directory:"$curr_direc
python=/ebio/abt6_projects9/metagenomic_controlled/Programs/anaconda3/bin/python

#########################################################################
## Gather kreports and separate by family
#########################################################################
conda activate pathodopsis

#use kraken-biom to aggregate the kraken output
kreports=($curr_direc/centrifuge_output/*.out.kreport)

#now pass the kreports array to kraken-biom to make the tsv classified only at the family level
kraken-biom "${kreports[@]}" -o $curr_direc/centrifuge_output/all_families_table.tsv --fmt tsv -v --max F --min F

# $python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/process_centrifuge.py
# $python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/classify_eukaryote_prokaryote.py

# $python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/process_centrifuge.py
$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/classify_eukaryote_prokaryote_v2.py

#########################################################################
## Recalibrate
#########################################################################

#4 Feed output from #3 into recalibrate which outputs normalized data files
$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/recalibrate_metagenome_table_centrifuge_v2.py \
	-meta $curr_direc/centrifuge_output/centrifuge_metagenome_table_bac.txt -host $curr_direc -org bacteria -resize 3870000 -min_recal 3870000 >>$curr_direc/centrifuge_output/family_present.txt

$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/recalibrate_metagenome_table_centrifuge_v2.py \
	-meta $curr_direc/centrifuge_output/centrifuge_metagenome_table_oom.txt -host $curr_direc -org oomycete -resize 37000000 -min_recal 37000000 >>$curr_direc/centrifuge_output/family_present.txt

$python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/recalibrate_metagenome_table_centrifuge_v2.py \
	-meta $curr_direc/centrifuge_output/centrifuge_metagenome_table_fungi.txt -host $curr_direc -org fungi -resize 8970000 -min_recal 8970000 >>$curr_direc/centrifuge_output/family_present.txt


#5 Graph output from #4
# $python /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/visualize_metagenomes.py

