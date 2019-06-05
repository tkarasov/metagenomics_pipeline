#!/usr/bin/sh

#This script takes a path to the ncbi genome and calculates the size of the genome

rsync --copy-links --times --verbose rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/696/305/GCF_001696305.1_UCN72.1/GCF_001696305.1_UCN72.1_genomic.gbff.gz my_dir/
size=`zcat $1 |awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}'`
rm $file