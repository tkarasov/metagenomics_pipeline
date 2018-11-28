#!/usr/bin/sh

#$ -cwd
#$ -l h_vmem=64G
#$ -pe parallel 4
#$ -e error_centrifuge.out
#$ -o output_centrifuge.out
#$ -N sweden_centrifuge_controlled_metagenomics


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
start=$(date +%s.%N)
full_dir=/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/swedish_samples/
mkdir $full_dir/centrifuge_output
#/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/
cd $full_dir
rm $full_dir/centrifuge_output/all_fastq_unpaired
touch $full_dir/centrifuge_output/all_fastq_unpaired

for mfile in `ls | grep R1.fq`;
    do full_dir=`pwd`;
    samplename=`echo $mfile | sed -r 's/.R1.fq//g'`
    echo -e "2\t"$full_dir/$samplename.R1.fq"\t"$full_dir/$samplename.R2.fq"\t" $full_dir/centrifuge_output/$mfile.out"\t"$full_dir/centrifuge_output/$mfile.report >> $full_dir/centrifuge_output/all_fastq_unpaired ; done

/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline_software/bin/centrifuge -x /ebio/abt6_projects9/metagenomic_controlled/database/nt \
    --threads 4 \
    --sample-sheet $full_dir/centrifuge_output/all_fastq_unpaired

end=$(date +%s.%N)
runtime=$(python -c "print(${end} - ${start})")

echo "Runtime was $runtime"
