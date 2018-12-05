import csv
from ete3 import NCBITaxa
import pandas as pd
import numpy as np
import sys

'''the goal of this script is to process the output from centrifuge to give genus or family-level comparisons of composition'''

#first variable is list of metagenomes to include in the table
#metagenome_list=sys.argv[1]
ncbi = NCBITaxa()

def get_desired_ranks(taxid, desired_ranks):
    try:
        lineage = ncbi.get_lineage(taxid)
        names = ncbi.get_taxid_translator(lineage)
        lineage2ranks = ncbi.get_rank(names)
        ranks2lineage = dict((rank,taxid) for (taxid, rank) in lineage2ranks.items())
        #rank_dict[taxid] = list(names.values())
        return{'{}_id'.format(rank): ranks2lineage.get(rank, '<not present>') for rank in desired_ranks}
    except ValueError:
        return{'{}_id'.format(rank):'<not present>' for rank in desired_ranks}

    #return rank_dict

def process_centrifuge_report(input_report_file_name, classification_level):
    print("Processing centrifuge output")
    desired_ranks = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    cent_out=pd.read_csv(input_report_file_name, sep='\t')
    taxids=cent_out['taxID']
    keep_class={}
    for taxid in taxids:
        #print(list(ncbi.get_taxid_translator([taxid]).values())[0])
        tax_dict = get_desired_ranks(taxid, desired_ranks)
        #for key, rank in ranks.items():
        #    if rank != '<not present>':
        #        print(key + ': ' + list(ncbi.get_taxid_translator([rank]).values())[0])
        #print('=' * 60)

        #need to limit results to fungus, oomycete, bacteria and virus
        fungi=4751
        oomycete=4762
        bacteria=2
        proteobacteria=1224
        virus=10239

        if len(set([fungi,oomycete,bacteria,virus,proteobacteria]).intersection(set(tax_dict.values())))==0:
            #print(tax_dict.values())
            pass
        elif classification_level=="family":
            try:
                keep_class[taxid]=tax_dict["family_id"]
            except KeyError:
                keep_class[taxid]='<not present>'
        elif classification_level=="genus":
            try:
                keep_class[taxid]=tax_dict["genus_id"]
            except KeyError:
                keep_class[taxid]='<not present>'
        elif classification_level=="species":
            try:
                keep_class[taxid]=tax_dict["species_id"]
            except KeyError:
                keep_class[taxid]='<not present>'
    return keep_class

def aggregate_reads(keep_class, cent_out):
    '''aggregates all reads of a given classification level'''
    unique_reads=cent_out[['taxID', 'numUniqueReads']]
    unique_reads['names']=[keep_class.get(key) for key in unique_reads['taxID']]
    unique_agg=unique_reads.groupby('names').sum()
    thing=[]
    for taxid in unique_agg.index:
        if taxid!="<not present>":
            lineage = ncbi.get_lineage(taxid)
            names = ncbi.get_taxid_translator(lineage)
            my_name=names[taxid]
            thing.append(my_name)
        else:
            thing.append("None")
    unique_agg['other_name']=thing
    sample_info=unique_agg['numUniqueReads']
    sample_info.index=unique_agg['other_name']
    return sample_info


if __name__ == '__main__':
    metagenome_info={}
    classification_level='family'
    #now build full metagenome table
    metagenome_list=[line.strip().split()[0] for line in open("metagenomic_report.txt").readlines()]
    microbes=[]
    input_report_file_name="Tjor-2MetagenomicR1R2.fq.gz.report"
    set_class=set()
    for input_report_file_name in metagenome_list:
        cent_out=pd.read_csv(open(input_report_file_name, 'rb'), sep='\t')
        keep_class=process_centrifuge_report(input_report_file_name, classification_level)
        sum_class=aggregate_reads(keep_class, cent_out)
        set_class=set_class.union((sum_class).index)
        metagenome_info[input_report_file_name]=sum_class
        #microbes.append(sum_class['other_name'])

    final_table=pd.DataFrame(index=set_class, columns=metagenome_list)
    for sample in list(metagenome_info.keys()):
        for rec in metagenome_info[sample].index:
            final_table[sample].loc[rec]=metagenome_info[sample][rec]

    final_table=final_table.fillna(0)

    final_table.to_csv("centrifuge_metagenome_table.txt", sep="\t")





