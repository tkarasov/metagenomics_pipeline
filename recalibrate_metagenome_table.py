#!/usr/bin/env python

#the goal of this script is to take a metagenome table and recalibrate based off of the average size per genus. The script takes the output file from

import argparse
import os, sys, pickle, copy, subprocess
import numpy as np
import pandas as pd
import warnings
warnings.filterwarnings("ignore") #some compatibility issue with
'''
USAGE EXAMPLE
./recalibrate_metagenome_table -gen_dict genome_size_dict -meta metagenome_table -host tosal_read_count.txt

Assumes 150bp reads****
'''
parser = argparse.ArgumentParser(description = \
    'recalibrate: Software for computing the read coverage per genus from a metagenome.', usage='./%(prog)s'+' -h (help)')
#parser.add_argument('-gen_dict', '--genus_dictionary', type=str, required = True, help = "Full path to pickled dictionary of genus to genus average size mapping generated by calc_genus_average.py")
parser.add_argument('-meta', '--metagenome', type=str, required = True,
    help = "Exported metagenome table from megan sans #")
parser.add_argument('-host', '--host_dir', type=str, help = "Directory for all bam files to which host was mapped.")
parser.add_argument('-read_len', '--read_length', type=float, default = 150)

params = parser.parse_args()

print("Running Metagenome Recalibrator")


def convert_read_coverage(meta_genus, genus_dic):
    meta_genus_new = copy.deepcopy(meta_genus)
    for genus in meta_genus.index:
        try:
            size = genus_dict[genus][0]*1000000
            reads = meta_genus.loc[genus]*150.0
            coverage = reads/size
            meta_genus_new.loc[genus] = coverage
            print(coverage)
        except KeyError:
            pass
    return meta_genus_new

def calculate_percent_mapped(sample):
    '''this function caluclates the ratio of reads mapped to TAIR10 vs unmapped'''
    sample_map = float(subprocess.check_output(['/usr/bin/samtools', 'view', '-c', sample+'.bam']))
    sample_unmap =float(subprocess.check_output(['/usr/bin/samtools', 'view', '-c', sample+'unmapped.bam']))
    sample_total = sample_unmap + sample_map
    return sample_map, sample_unmap, sample_total

def findfiles(path):
    all_bam ={}
    for root,dirs,fnames in os.walk(path):
        for fname in fnames:
            if "unmapped.bam" in fname:
                unmapped_file = fname
                sample = fname.replace("unmapped", "").replace(".bam", "")
                all_bam[sample] = calculate_percent_mapped(sample)
    return all_bam

def convert_per_plant(meta_corrected, all_bam, genus_dict):
    '''output coverage per genome microbe divided by coverage per genome of A. thaliana'''
    athal_cov = {}
    meta_corrected_new = copy.deepcopy(meta_corrected)
    athal = genus_dict["Arabidopsis"][0]
    for key in list(all_bam.keys()):
        bp_cov = read_len*all_bam[key][0]/float(athal * 1000000)
        athal_cov[key] = bp_cov
        try:
            meta_corrected_new[key]=meta_corrected[key]/bp_cov
        except KeyError:
            print("Issue with " + key)
            pass
    return meta_corrected_new

def genus_family(genus_dict, meta_genus):
    '''this is a bad ad-hoc function to calculate the genome size average for a family overall'''
    genus_family_dict = {}
    for rec in meta_genus.index:
        family = rec.split(";")[6]
        genus = rec.split(";")[7]
        genus_family_dict[genus] = family
    family_size = {key:[] for key in set(genus_family_dict.values())}
    for genus_full in meta_genus.index:
        if len(genus_full.split(";"))==9:
            #I don't like the previous condition but its a way to limit to only those at genus level
            genus = genus_full.split(";")[7]
            try:
                size = genus_dict[genus][0]
                family = genus_family_dict[genus]
                family_size[family].append(size)
            except KeyError:
                print("No result for " + genus)
    family_final = {}
    for key in family_size:
        family_final[key] = [np.mean(family_size[key]), 0]
    return genus_family_dict, family_final





#if __name__ == '__main__':
#params = parser.parse_args()
#genus_size = params.genus_dictionary
genus_size = "/ebio/abt6_projects9/metagenomic_controlled/code/genus_dict.pck"
metagenome = params.metagenome
read_len = params.read_length
host_reads = params.host_dir


metagenome_data = pd.read_csv(metagenome, error_bad_lines=False, sep = '\t', header = 0, index_col = 0)
genus_dict = pickle.load(open(genus_size, 'rb'))
#tot = {q}
#pd.read_csv("/ebio/abt6_projects9/pathodopsis_microbiomes/data/processed_reads/2018_7_metagenome_reads/metagenome_all_summarized.txt", error_bad_lines=False, sep = '\t', header = 0, index_col = 0)
#metagenome_data = pd.read_csv("/ebio/abt6_projects9/metagenomic_controlled/data/metagenome_tables/dc3000_88_compared.txt", error_bad_lines=False, sep = '\t', header = 0, index_col = 0)


#meta_genus = metagenome_data.loc[[rec for rec in metagenome_data.index if "Genus:" in rec]]
#meta_genus.index = [line.strip("Genus:").strip('"') for line in meta_genus.index]
meta_genus = metagenome_data.loc[[rec for rec in metagenome_data.index if len(rec.split(";")) == 9]]

genus_family_dict, family_average = genus_family(genus_dict, meta_genus)

meta_family = copy.deepcopy(meta_genus)
meta_family.index = [line.split(";")[6] for line in meta_genus.index]
meta_family_group = meta_family.groupby(meta_family.index).sum()
meta_genus.index = [line.split(";")[7] for line in meta_genus.index]



#generate table with everything converted to coverage per genome
meta_corrected = convert_read_coverage(meta_genus, genus_dict)
meta_family_correct = convert_read_coverage(meta_genus, family_average)

#go through every bam file in directory
all_bam = findfiles(host_reads)

#convert meta table to read coverage per genome per athal coverage
meta_corrected_per_plant = convert_per_plant(meta_corrected, all_bam, genus_dict)
meta_family_per_plant = convert_per_plant(meta_corrected, all_bam, genus_dict)


#output converted table
meta_corrected_per_plant.to_csv("meta_genus_corrected_per_plant.csv", header = True, index = True)
meta_family_per_plant.to_csv("meta_family_corrected_per_plant.csv", header = True, index = True)