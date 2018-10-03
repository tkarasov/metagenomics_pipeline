## metagenomics_pipeline
This pipline was originally developed by Julian Regalado. Talia Karasov took the pipeline and is continuously adpating for her own purposes.
Readme explain how to use a series of scripts in order to easily run and analyze metagenomic set derived from plant phylosphere. This pipeline ofcourse is not extensive and much more work can be done in addition to what is done in this repository. If you have any suggestion please let me know via issues. 

The following scripts permit the analysis of plant metagenomes. From filtering of plant data to taxonomic binning of microbial reads based on mappings to a reference database. 

Some scripts perform several tasks using different software packages. You can use the dependencyCheck.sh script to check and install and missing programs. 

All programs can be ran as shell scripts in any linux system. You can also submit them to the SGE queuing system in case you want to execute all programs in a cluster.

Ignore image, will make sense in the future

<p align="center">
 <img src=".drawings/drawing.svg">
</p>

# Get it!!!
The following script and commands were first primarly developed by Juliana Regalado then developed further by Talia Karasov. The foolwing will download this repository and some of it's dependencies. It is important to execute the last "export" command in order for your system to execute the scripts without specifying full paths 

       git clone --recursive https://github.com/tkarasov/metagenomics_pipeline.git
       cd metagenomics_pipeline
       # Add current directory to your PATH environmental variable so all scripts can be ran
       export PATH=$PATH:$(pwd)
In order to get future updates, make sure to regularly execute:

       git pull
       
This will automatically apply any change made to any of the files in this repository
       
# Check you have all the software needed to run the scripts

       source dependencyCheck.sh

This will look for the necessary software in your computer. If certain program is not found, it will be installed in the same folder.


# run_plantRemoval_tlk.sh

Mapps short reads against the TAIR 10 reference genome. Removes PCR and optical duplicates from the bam file for downstraem use of host derived data (Eg. SNP calling) and extract unmapped read pairs to be trated as putatively microbial for downstream analysis.

Execution:


       bash run_plantRemoval.sh samplename read1.fq read2.fq
       or
       qsub -N samplename -o plantRemoval.out -e plantRemoval.err run_plantRemoval.sh samplename read1.fq read.fq


Input: 

       samplename - name of the sample to be processed. Important output files will have this name as a basename
       
       read1.fq   - path to first pairs of short read sequences. Can be gzip compressed
       
       read2.fq   - path to second pairs of short read sequences. Can be gzip compressed
       
Output: 

       logs                               - folder where the logging data  files will be stored
        
        <samplename>.bam                   - Mapping file with host data and duplicates removed
        
        <samplename>MetagenomicR1R2.fq.gz  - Interleaved fastq file with unmapped read pairs (putatively microbial)
        
        <samplename>S.fq.gz                - Single end fastq file with unmapped reads where one pair mapped to TAIR10

NOTE!! - If your input reads are interleaved in a single file. You can separate them with:
       
       zcat readsR1R2.fa.gz | paste - - - - |awk -F '\t' -v OFS='\n' '{print $1,$2,$3,$4 > read1.fq;print $5,$6,$7,$8 > read2.fq}'
       
You can also modify the script by adding the "-p" flag after "mem" and providing your interleaved file as read1.fq

# run_diamond_tlk.sh
After running run_plantRemoval.sh the output file <samplename>Metagenomic.fq.gz will have been produced with <samplename> being the basename with wich run_plantRemoval.sh was run. run_diamond.sh mapps reads in <samplename>Metagenomic.sh against the NCBI NR database. 

Execution:

       bash run_diamond.sh <samplename> <samplename>Metagenomic.fq.gz
       or
       qsub -N <samplename> -o diamond.out -e diamond.err run_diamond.sh <samplename> <samplename>Metagenomic.fq.gz
       
Input:

       <samplename> - name of the sample to be processed. Important output files will have this name as a basename
       
       <samplename>Metagenomic.fq.gz - Interleaved fastq file with unmapped read pairs (putatively microbial)


Output:

       <samplename>.daa - Alignement file in Diamond Alignemnt Archive format

       unaligned.fa.gz - Unaligned reads in FASTA format. These are reads that did not map any reference sequence in the database


# run_diamond-meganizer_tlk.sh
After running run_diamond.sh, the output file <samplename>.daa will have been produced with <samplename> being the basename with wich run_diamond.sh was run. This script will perfomr taxonomic binning of aligned reads and reformat the .daa file so that it can be opened with MEGAN.
       
Execution:

       bash run_diamond-meganizer.sh <samplename>.daa
       or
       qsub -N <samplename> -o meganizer.out -e meganizer.err run_diamond-meganizer.sh <samplename>.daa
       
Input:

       <samplename>.daa - daa file to be meganized

Output:

       <samplename>.daa - meganized daa file
       
       
By now you have a "meganized" dimond file, this means that your metagenomic analysis is ready to be visualized!! For this you will have to use MEGAN (http://ab.inf.uni-tuebingen.de/software/megan6/). 

# Using Megan

# Coverage Correction after MEGAN output table is generated
