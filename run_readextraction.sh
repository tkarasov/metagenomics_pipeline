#!/bin/sh
#  Import environment
#$ -V
#  Reserve 20 CPUs for this job
#$ -pe parallel 20
#
#  Request 20G of RAM 
#$ -l h_vmem=1G
#  Limit run time to 1 hour for short queue
#$ -l h_rt=1:00:00
#
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
# -N 
#
#  The path used for the standard output stream of the job
# -o
#  The path used for standard error stream of the job
# -e
#
#
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#
#  Run job from current working directory
#$ -cwd
#
# Use node with less than 600G
# -l h=
#  Send email when the job begins, ends, aborts, or is suspended
#$ -m as


xvfb-run --auto-servernum --server-num=1 MEGAN -g -c extract_reads
