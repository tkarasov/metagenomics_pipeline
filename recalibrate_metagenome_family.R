#!/usr/bin/env Rscript 
args = commandArgs(trailingOnly = TRUE)
library("taxize")

#the goal of this script is to take a metagenome table

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
}

meta_table = read.table("/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/dc3000_all_summarized_metagenome_table_10_2018.txt", header = 1, row.names = 1, sep ="\t")
#meta = args[1]
