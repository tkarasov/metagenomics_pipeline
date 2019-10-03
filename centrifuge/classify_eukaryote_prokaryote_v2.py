#!/usr/bin/env python

import csv
import os
from ete3 import NCBITaxa
import pandas as pd
import numpy as np
import sys
import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")

'''the goal of this script is to process the output from centrifuge to give genus or family-level comparisons of composition separated by eukaryote or prokaryote. This is the second version of this script as the first centrifuge pipeline had a major error'''

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


###########################################################################
# Build dictionaries of taxid mappings and separate kingdoms
###########################################################################
    #Go through OTU ID, find classification and put into file
    fungi_map=[]
    oom_map=[]
    bac_map=[]
    other_map=[]
    desired_ranks = ['superkingdom', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    missing = []

    for taxid in metagenome.index:
        tax_dict = get_desired_ranks(taxid, desired_ranks)
        famid = get_desired_ranks(taxid, ['family'])['family_id']
        if famid == '<not present>':
            missing.append(taxid)
        else:
            lineage = ncbi.get_lineage(taxid)
            names = ncbi.get_taxid_translator(lineage)
            fam = list(ncbi.get_taxid_translator([famid]).values())[0]

            if 4751 in list(tax_dict.values()):
                fungi_map.append((taxid, fam))
            elif 4762 in list(tax_dict.values()):
                oom_map.append((taxid, fam))
            elif 2 in list(tax_dict.values()):
                bac_map.append((taxid, fam))
            else:
                other_map.append((taxid,names))


    bac_table = metagenome.loc[[rec[0] for rec in bac_map]]
    bac_table['family'] = [rec[1] for rec in bac_map]
    fung_table = metagenome.loc[[rec[0] for rec in fungi_map]]
    fung_table['family'] = [rec[1] for rec in fungi_map]
    oom_table = metagenome.loc[[rec[0] for rec in oom_map]]
    oom_table['family'] = [rec[1] for rec in oom_map]

###########################################################################
# Generate final output tables
###########################################################################
    bac_table.to_csv(os.getcwd() + "/centrifuge_output/centrifuge_metagenome_table_bac.txt", sep="\t")

    oom_table.to_csv("./centrifuge_output/centrifuge_metagenome_table_oom.txt", sep="\t")

    fung_table.to_csv("./centrifuge_output/centrifuge_metagenome_table_fungi.txt", sep="\t")
