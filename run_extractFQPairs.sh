#!/bin/sh
#  Import environment
#$ -V
#  Reserve 20 CPUs for this job
#$ -pe parallel 3
#
#  Request 9G of RAM 
#$ -l h_vmem=3G
#  Limit run time to 1 hour for short queue
#$ -l h_rt=4:00:00
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

unaligned=$1
binned=$2
fqfile=$3


mkdir -p for_assembly
join -1 1 -2 1 <(zcat "$unaligned" | paste - - | cut -c2- | sort -k1,1) <(zcat "$fqfile" | paste - - - - | cut -c2- | sort -k1,1) | cut -d ' ' -f1,3,4,5 | sed "s/^/@/g"| sed "s/ /\t/g" | keep_paired.py \/ for_assembly/unalignedR1R2.fq unalignedS.fq

join -1 1 -2 1 <(cat "$binned" | paste - - | cut -c2- | sort -k1,1) <(zcat "$fqfile" | paste - - - - | cut -c2- | sort -k1,1) | cut -d ' ' -f1,3,4,5 | sed "s/^/@/g"| sed "s/ /\t/g" | keep_paired.py \/ for_assembly/noPlantR1R2.fq noPlantS.fq

cat noPlantS.fq unalignedS.fq | sed '/^$/d' | paste - - - - | sed '/^\s*$/d' | sort -k1,1 | keep_paired.py \/ for_assembly/otherR1R2.fq /dev/null

rm noPlantS.fq unalignedS.fq
gzip -9 for_assembly/unalignedR1R2.fq &
gzip -9 for_assembly/noPlantR1R2.fq &
gzip -9 for_assembly/otherR1R2.fq &
wait


