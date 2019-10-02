#!/usr/bin/env python

import csv
import os
from ete3 import NCBITaxa
import pandas as pd
import numpy as np
import sys
import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")

'''the goal of this script is to process the output from centrifuge to give genus or family-level comparisons of composition separated by eukaryote or prokaryote'''

# first variable is list of metagenomes to include in the table
# metagenome_list=sys.argv[1]
ncbi = NCBITaxa()


def get_desired_ranks(taxid, desired_ranks):
    try:
        lineage = ncbi.get_lineage(taxid)
        names = ncbi.get_taxid_translator(lineage)
        lineage2ranks = ncbi.get_rank(names)
        ranks2lineage = dict((rank, taxid) for (taxid, rank) in lineage2ranks.items())
        #rank_dict[taxid] = list(names.values())
        return{'{}_id'.format(rank): ranks2lineage.get(rank, '<not present>') for rank in desired_ranks}

    except ValueError:
        return{'{}_id'.format(rank): '<not present>' for rank in desired_ranks}


def process_centrifuge_report(input_report_file_name, classification_level):
    print("Processing centrifuge output")
    desired_ranks = ['superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    cent_out = pd.read_csv(input_report_file_name, sep='\t')
    taxids = cent_out['taxID']
    keep_class = {}

    for taxid in taxids:
        tax_dict = get_desired_ranks(taxid, desired_ranks)

        # need to limit results to fungus, oomycete, bacteria and virus
        fungi = 4751
        oomycete = 4762
        bacteria = 2
        proteobacteria = 1224
        virus = 10239

        if len(set([fungi, oomycete, bacteria, virus, proteobacteria]).intersection(set(tax_dict.values()))) == 0:
            # print(tax_dict.values())
            pass
        elif classification_level == "family":
            try:
                keep_class[taxid] = tax_dict["family_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'
        elif classification_level == "genus":
            try:
                keep_class[taxid] = tax_dict["genus_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'
        elif classification_level == "species":
            try:
                keep_class[taxid] = tax_dict["species_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'

    return keep_class


def process_centrifuge_report_specify_kingdom(input_report_file_name, classification_level, kingdom):
    '''function that builds dictionary for level of classification'''
    print("Processing centrifuge output")
    desired_ranks = ['superkingdom', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    cent_out = pd.read_csv(input_report_file_name, sep='\t')
    taxids = cent_out['taxID']
    keep_class = {}

    for taxid in taxids:
        tax_dict = get_desired_ranks(taxid, desired_ranks)
        # hm.append(tax_dict['kingdom_id'])
        if len(set([kingdom]).intersection(set(tax_dict.values()))) == 0:
            pass
        elif classification_level == "family":
            try:
                keep_class[taxid] = tax_dict["family_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'
        elif classification_level == "genus":
            try:
                keep_class[taxid] = tax_dict["genus_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'
        elif classification_level == "species":
            try:
                keep_class[taxid] = tax_dict["species_id"]
            except KeyError:
                keep_class[taxid] = '<not present>'

    return keep_class




def generate_table(metagenome_list, kingdom):
    set_class = set()
    metagenome_info = {}

    for input_report_file_name in metagenome_list:
        cent_out = pd.read_csv(open(input_report_file_name, 'rb'), sep='\t')
        keep_class = process_centrifuge_report_specify_kingdom(input_report_file_name, classification_level, kingdom)
        sum_class = aggregate_reads(keep_class, cent_out)
        set_class = set_class.union((sum_class).index)
        metagenome_info[input_report_file_name] = sum_class
        # microbes.append(sum_class['other_name'])

    final_table = pd.DataFrame(index=set_class, columns=metagenome_list)

    for sample in list(metagenome_info.keys()):
        for rec in metagenome_info[sample].index:
            final_table[sample].loc[rec] = metagenome_info[sample][rec]

    final_table = final_table.fillna(0)

    return final_table


if __name__ == '__main__':
    classification_level = 'family'

    # now build full metagenome table

    metagenome = pd.read_csv("./centrifuge_output/all_families_table.tsv", sep="\t", skiprows=1, header=0, index_col=0)
    # need to limit results to fungus, oomycete, bacteria and virus
    fungi = 4751
    oomycete = 4762
    eukarya = 2759
    # eukarya is not good because it captures plant also
    bacteria = 2
    proteobacteria = 1224
    virus = 10239
    archaea = 2157

    #Go through OTU ID, find classification and put into file
    fungi_map=[]
    oom_map=[]
    bac_map=[]
    other_map=[]
    desired_ranks = ['superkingdom', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    for taxid in metagenome.index:
        tax_dict = get_desired_ranks(taxid, desired_ranks)
        lineage = ncbi.get_lineage(taxid)
        names = ncbi.get_taxid_translator(lineage)
        if 4751 in list(tax_dict.values()):
            fungi_map.append((taxid)
        elif 4762 in list(tax_dict.values()):
            oom_map.append(taxid)
        elif 2 in list(tax_dict.values()):
            bac_map.append(taxid)
        else:
            other_map.append(taxid)

    bac_table = metagenome.loc[bac_map]
    fung_table = metagenome.loc[fungi_map]
    oom_table = metagenome.loc[oom_map]





    final_bac = generate_table(metagenome_list, bacteria)
    final_bac.to_csv(os.getcwd() + "/centrifuge_output/centrifuge_metagenome_table_bac.txt", sep="\t")
    #final_euk=generate_table(metagenome_list, eukarya)
    #final_euk.to_csv("centrifuge_metagenome_table_eukarya.txt", sep="\t")
    #final_vir = generate_table(metagenome_list, virus)
    #final_vir.to_csv("./centrifuge_output/centrifuge_metagenome_table_virus.txt", sep="\t")
    final_arc = generate_table(metagenome_list, archaea)
    final_arc.to_csv("./centrifuge_output/centrifuge_metagenome_table_archaea.txt", sep="\t")
    final_oom = generate_table(metagenome_list, oomycete)
    final_oom.to_csv("./centrifuge_output/centrifuge_metagenome_table_oom.txt", sep="\t")
    final_fung = generate_table(metagenome_list, fungi)
    final_fung.to_csv("./centrifuge_output/centrifuge_metagenome_table_fungi.txt", sep="\t")
