#!/usr/bin/bash
#  Reserve 8 CPUs for this job
#$ -pe parallel 2
#  Request 64G of RAM
#$ -l h_vmem=64G
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N run_centrifuge.$1
# contains both the real output and the error messages.
#$ -e error_centrifuge_total.out
#$ -o output_centrifuge_total.out
#$ -j y
#  Use /bin/bash to execute this script
#$ -S /bin/bash
#$ -cwd
#this script takes the cleaned and parsed reads puts through centrifuge

start=$(date +%s.%N)
curr_direc=$1
split=$2

echo "The full directory going into centrifuge_db is":$curr_direc
#rm -r $curr_direc/centrifuge_output
mkdir $curr_direc/centrifuge_output
#/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/
cd $curr_direc
#rm $curr_direc/centrifuge_output/all_fastq_paired
#touch $curr_direc/centrifuge_output/all_fastq_unpaired

# for mfile in `ls | grep R1.fq`;
#     do curr_direc=`pwd`;
#     samplename=`echo $mfile | sed -r 's/.R1.fq//g'`
#     echo $samplename
#     echo -e "2\t"$curr_direc/$samplename.R1.fq"\t"$curr_direc/$samplename.R2.fq"\t" $curr_direc/centrifuge_output/$mfile.out"\t"$curr_direc/centrifuge_output/$mfile.report >> $curr_direc/centrifuge_output/all_fastq_paired ; done

echo "Running centrifuge..."
/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge -x /ebio/abt6_projects9/metagenomic_controlled/database/nt \
    --threads 2 \
    --sample-sheet $curr_direc/centrifuge_output/$split

# #now generate centrifuge kreport
# for file in `ls $curr_direc/centrifuge_output | grep out`;
#     do /ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge-kreport -x /ebio/abt6_projects9/metagenomic_controlled/database/nt $file;
#     done

# end=$(date +%s.%N)
# runtime=$(python -c "print(${end} - ${start})")

# echo "Runtime was $runtime"






#https://github.com/infphilo/centrifuge/blob/master/MANUAL.markdown#centrifuge-example
#https://ccb.jhu.edu/software/centrifuge/manual.shtml

# -x is name of index
# -1 Comma-separated list of files containing mate 1s (filename usually includes _1), e.g. -1 flyA_1.fq,flyB_1.fq. Sequences specified with this option must correspond file-for-file and read-for-read with those specified in <m2>. Reads may be a mix of different lengths. If - is specified, centrifuge will read the mate 1s from the "standard in" or "stdin" filehandle.
# -2 Comma-separated list of files containing mate 2s (filename usually includes _2), e.g. -2 flyA_2.fq,flyB_2.fq. Sequences specified with this option must correspond file-for-file and read-for-read with those specified in <m1>. Reads may be a mix of different lengths. If - is specified, centrifuge will read the mate 2s from the "standard in" or "stdin" filehandle.
#--sample-sheet <s> s is a 5-column TSV file where each line corresponds to a sample. The format for the sample sheet file is: the first column specify the sample type: 1: single-end, 2:paired-end. The next two column will specify the read file(s) followed by the classification result output file and report file. If the sample is single-ended (type 1), the third column will be ignored by Centrifuge.
#-S <filename> File to write classification results to. By default, assignments are written to the "standard out" or "stdout" filehandle (i.e. the console).
#--report-file <filename>
# --threadsS is nubmer of threads File to write a classification summary to (default: centrifuge_report.tsv).


#BUILDING INDEX OF COMPLETE GENOMES!!
#burrito seems to block  ftp connections so the download options had to be run on my personal computer
#/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge-download -o taxonomy taxonomy
#/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge-download -o arch_bacteria_viral_fungi -m -d "archaea,bacteria,viral,fungi" refseq > seqid2taxid.map
#cat arch_bacteria_viral_fungi/*/*.fna > input-sequences.fna
## build centrifuge index with 4 threads
#centrifuge-build -p 4 --conversion-table seqid2taxid.map --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp  input-sequences.fna abvf
