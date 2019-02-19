#!/usr/bin/env python

# the goal of this script is to take a metagenome table and recalibrate based off of the average size per genus. The script takes the output file from centrifuge then run through process_centrifuge.py (note the other script takes the output from malt/megan)

import argparse
import os
import sys
import pickle
import copy
import subprocess
import numpy as np
import pandas as pd
import warnings
import ete3
warnings.filterwarnings("ignore", message="numpy.dtype size changed") # some compatibility issue with numpy
'''
USAGE EXAMPLE
./recalibrate_metagenome_table -gen_dict genome_size_dict -meta metagenome_table -host total_read_count.txt

Assumes 150bp reads****
'''
parser = argparse.ArgumentParser(description='recalibrate: Software for computing the read coverage per genus from a metagenome.', usage='./%(prog)s' + ' -h (help)')
#parser.add_argument('-gen_dict', '--genus_dictionary', type=str, required = True, help = "Full path to pickled dictionary of genus to genus average size mapping generated by calc_genus_average.py")
parser.add_argument('-meta', '--metagenome', type=str, required=True,
                    help="Exported metagenome table from centrifuge")
parser.add_argument('-host', '--host_dir', type=str, help="Directory for all bam files to which host was mapped.")
parser.add_argument('-read_len', '--read_length', type=float, default=150)

params = parser.parse_args()

print("Running Metagenome Recalibrator")


def convert_read_coverage(meta_phy, phy_dict):
    meta_phy_new = copy.deepcopy(meta_phy)
    for phy in meta_phy.index:
        try:
            size = phy_dict[phy][0] * 1000000
            if size < 2000000:
                size = 10000000
            reads = meta_phy.loc[phy] * 150.0
            coverage = reads / size
            meta_phy_new.loc[phy] = coverage
            # print(coverage)
        except KeyError:
            print(phy)
            coverage = reads / 50000000
            meta_phy_new.loc[phy] = coverage
    return meta_phy_new


def calculate_percent_mapped(sample):
    '''this function caluclates the ratio of reads mapped to TAIR10 vs unmapped'''
    sample_map = float(subprocess.check_output(['/usr/bin/samtools', 'view', '-c', sample + '.bam']))
    sample_unmap = float(subprocess.check_output(['/usr/bin/samtools', 'view', '-c', sample + 'unmapped.bam']))
    sample_total = sample_unmap + sample_map
    return sample_map, sample_unmap, sample_total


def correct_depth(path):
    '''before I was using the bam files to calculate average coverage but instead Ill use the depth function which is faster. The very last line of the depth file is the average depth for the nuclear portion'''
    all_depth = {}
    for root, dirs, fnames in os.walk(path):
        for fname in fnames:
            if "depth" in fname:
                #sample = desired_file.replace(".depth", "")
                sample=fname
                print(sample)
                error_depth = []
                depth=subprocess.check_output(['tail','-1',sample])
                all_depth[sample.strip(".depth")] = float(depth.strip())
                    #calculate_percent_mapped(path + "/"+sample)
    return all_depth


'''def findfiles(path):
this deprecated function calculates percent mapped for all bam files and can take some time
    all_bam = {}
    for root, dirs, fnames in os.walk(path):
        for fname in fnames:
            if "unmapped.bam" in fname:
                unmapped_file = fname
                sample = fname.replace("unmapped", "").replace(".bam", "")
                error_bam = []
                try:
                    all_bam[sample] = calculate_percent_mapped(path + sample)
                except subprocess.CalledProcessError:
                    error_bam.append(sample)
    return all_bam
'''


def convert_per_plant(meta_corrected, all_depth, genus_dict):
    '''output coverage per genome microbe divided by coverage per genome of A. thaliana'''
    athal_cov = {}
    # there have been problems with some bam files. Limit to those bam files that are fine.
    meta_corrected_new = {}#copy.deepcopy(meta_corrected)  # [list(all_bam.keys())]
    for rec in meta_corrected.keys():
        new=rec.split("/")[-1].split(".R1.fq.report")[0]
        print(rec)
        meta_corrected_new[new]=meta_corrected[rec] / all_depth[new]

    #athal = genus_dict["Arabidopsis"][0]
    '''for key in list(all_depth.keys()):
        bp_cov = all_depth[key]#read_len * all_depth[key][0] / float(athal * 1000000)
        #athal_cov[key] = bp_cov
        try:
            meta_corrected_new[key] = meta_corrected_new[key] / bp_cov
        except KeyError:
            print("Issue with " + key)
            pass
    '''
    return pd.DataFrame.from_dict(meta_corrected_new)


def gather_tree_family_genus(genus_dict):
    '''this function gathers the newick tree from MEGAN genera and gives all genera belonging to a specific family'''
    megan_tree = ete3.Tree("/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/data/megan_genus_tree_10_2_2018.tre", format=1)
    # now iterate through every leaf and indicate its parent node (the leaves are all genera)
    genus_family_map = {}
    for leaf in megan_tree.get_leaves():
        genus_family_map[leaf.name] = leaf.get_ancestors()[0].name
    family_average = {value: [] for value in set(genus_family_map.values())}
    for key in genus_family_map:
        try:
            size = genus_dict[key][0]
            fam = genus_family_map[key]
            family_average[fam].append(size)
        except KeyError:
            fam = genus_family_map[key]
            if len(family_average[fam]) > 0:
                print(family_average[fam])
                pass
            if len(family_average[fam]) == 0:
                family_average[fam].append(49.99999)
            # if there is no representation for genus give genome size of 50Mb
            # pass
    family_final = {}
    for key in family_average:
        if len([rec for rec in family_average[key] if rec != 49.99999]) > 0:
            fam_intermediate = [rec for rec in family_average[key] if rec != 49.99999]
            family_final[key] = [np.mean(fam_intermediate), 0]
        else:
            '''find average on another level'''
            family_final[key] = [50, 0]
    return family_final, genus_family_map


# if __name__ == '__main__':
#params = parser.parse_args()
#genus_size = params.genus_dictionary
genus_size = "/ebio/abt6_projects9/metagenomic_controlled/Programs/metagenomics_pipeline/data/genus_dict.pck"
metagenome = params.metagenome
read_len = params.read_length
host_reads = params.host_dir


metagenome_data = pd.read_csv(metagenome, error_bad_lines=False, sep='\t', header=0, index_col=0)
genus_dict = pickle.load(open(genus_size, 'rb'))
meta_family_group = metagenome_data.loc[[ind for ind in metagenome_data.index if ind != "None"]]
#meta_genus = metagenome_data


family_final, genus_family_dict = gather_tree_family_genus(genus_dict)


# generate table with everything converted to coverage per genome
#meta_corrected = convert_read_coverage(meta_genus, genus_dict)
meta_family_correct = convert_read_coverage(meta_family_group, family_final)

# go through every bam file in directory
all_depth = correct_depth(host_reads)

# convert meta table to read coverage per genome per athal coverage
#meta_corrected_per_plant = convert_per_plant(meta_corrected, all_bam, genus_dict)
meta_family_per_plant = convert_per_plant(meta_family_correct, all_depth, genus_dict)


# output converted table
#meta_corrected_per_plant.to_csv("meta_genus_corrected_per_plant.csv", header=True, index=True)
meta_family_per_plant.to_csv("meta_family_corrected_per_plant.csv", header=True, index=True)
