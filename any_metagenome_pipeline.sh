#!/bin/sh
#
#  Reserve 8 CPUs for this job
#$ -pe parallel 4
#  Request 168G of RAM
#$ -l h_vmem=32G
#$ -o $HOME/tmp/stdout_of_job
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N metagenome.$1
#  Run job from current working directory
# Merge stdout and stderr. The job will create only one output file which
# contains both the real output and the error messages.
#$ -j y
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#



#source /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/dependencyCheck.sh

#include full path of read1 and read2
samplename=$samplename
read1=$read1
read2=$read2
read_direc=$read_direc  #/ebio/abt6_projects9/metagenomic_controlled/data/raw_reads/rebecca_metagenome/RNAlater
curr_direc=$curr_direc

    cd $curr_direc #/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections
    echo "working in:" `pwd`
    echo "Reading now" $samplename, $read1, $read2, $read_direc
    #map plant reads
    bash /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/run_plantRemoval_tlk.sh $samplename $read1 $read2 $read_direc

    echo "Done with mapping reads, now running diamond"
    #run diamond
    bash /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/run_diamond_tlk.sh $samplename "$samplename"MetagenomicR1R2.fq.gz

    echo "Done with diamond, now onto meganizer"
    #run meganizer
    bash /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/run_diamond-meganizer_tlk.sh $samplename.daa
    done


