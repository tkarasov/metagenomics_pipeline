#!/bin/sh
#
#  Reserve 4 CPUs for this job
#$ -pe parallel 4
#  Request 32G of RAM
#$ -l h_vmem=32G
#$ -e trial_error_centrifuge.out
#$ -o trial_output_centrifuge.out
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N trial
#  Run job from current working directory
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#$ -cwd



/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge -x /ebio/abt6_projects9/metagenomic_controlled/database/nt -U /ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/EV_RVI-6MetagenomicR1R2.fq.gz -p 4 --met 1 --met-file /ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections -S trial.report
