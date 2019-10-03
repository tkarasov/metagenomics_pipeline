#!/usr/bin/bash
#
# $ -cwd

#########################################################################
## Setting the directory
#########################################################################
# This is the pipeline for running centrifuge and recalibrating centrifuge. Talia found an error on 10.1.2019 which caused her to totally revamp the pipeline

#change to the directory of reads
#curr_direc is the output directory

curr_direc=$curr_direc
read_direc=$read_direc
cd $curr_direc
echo "This is the directory:"$curr_direc
python=/ebio/abt6_projects9/metagenomic_controlled/Programs/anaconda3/bin/python

#########################################################################
## Map reads to plant
#########################################################################
#any_metagenome_pipeline_centrifuge.sh
#1 Run bwa mem to remove plant reads
#All files in this directory were generated with this script

i=$((1))
for samp_temp in `ls $read_direc | grep illumina`; do
    read1=$read_direc/$samp_temp/*R1*
    read2=$read_direc/$samp_temp/*R2*
    temp=`sed 's/_RunId0116_LaneId3//g' <<<$samp_temp`
    samplename=`sed 's/illumina_ST-J00101_flowcellA_SampleId//g' <<< $temp`
    qsub -N reads.patho.$i -v samplename=$samplename -v read1=$read1 -v read2=$read2 -v read_direc=$read_direc -v curr_direc=$curr_direc /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/any_metagenome_pipeline_centrifuge.sh
    i=$((i+1))
    done

#########################################################################
## Run centrifuge
#########################################################################
#Take unmapped reads and classify with centrifuge
#The above for loop will run all of the reads, clean them. Then we want to wait to submit centrifuge until the cleaned reads are done

qsub -hold_jid "reads.patho*" curr_direc=$curr_direc /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_step1_v2.sh

#########################################################################
## Make kreport
#########################################################################
#To submit an array job with -t, need to put 1-num_jobs (not just the number of jobs)
ls $curr_direc/centrifuge_output/*R1.fq.out > $curr_direc/centrifuge_output/metagenomic_out.txt

my_jobs=$((`wc -l $curr_direc/centrifuge_output/metagenomic_out.txt | awk '{print $1}'`))

qsub -hold_jid "run_centrifuge*" -t 1-$((my_jobs)) -v curr_direc=$curr_direc /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_step2_v2.sh

#########################################################################
## Recalibrate kreports
#########################################################################
qsub -hold_jid "make_kreport*" -v curr_direc=$curr_direc /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/centrifuge/centrifuge_total_step3_v2.sh
