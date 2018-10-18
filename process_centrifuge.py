import csv
from ete3 import NCBITaxa

ncbi = NCBITaxa()

def get_desired_ranks(taxid, desired_ranks):
    lineage = ncbi.get_lineage(taxid)
    names = ncbi.get_taxid_translator(lineage)
    lineage2ranks = ncbi.get_rank(names)
    ranks2lineage = dict((rank,taxid) for (taxid, rank) in lineage2ranks.items())
    return{'{}_id'.format(rank): ranks2lineage.get(rank, '<not present>') for rank in desired_ranks}

if __name__ == '__main__':
    taxids = [1204725, 2162,  1300163, 420247]
    desired_ranks = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
    for taxid in taxids:
        print(list(ncbi.get_taxid_translator([taxid]).values())[0])
        ranks = get_desired_ranks(taxid, desired_ranks)
        for key, rank in ranks.items():
            if rank != '<not present>':
                print(key + ': ' + list(ncbi.get_taxid_translator([rank]).values())[0])
        print('=' * 60)
