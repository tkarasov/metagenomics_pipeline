/usr/bin/python3
import os, sys, time,csv, glob
from collections import defaultdict
import urllib.request
from io import BytesIO
from zipfile import ZipFile
import gzip
import numpy as np
import pickle
#from urllib import urlopen

#the goal of this script is to pull all genera from ncbi for which full genomes are available, calculate average genome size (+/- sd).
'''

def fetch_all_complete():
    #the pulling from ftp doesn't work on burrito but does work on personal computer
    os.system('wget -c ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/assembly_summary_refseq.txt')
    infile='assembly_summary_refseq.txt'
    species_list=[]

    with open(infile, 'rt') as csvfile:
        csv_reader=csv.reader(csvfile, delimiter='\t')
        next(csv_reader)
        headers = next(csv_reader)
        for icsv_line in csv_reader:
            try:
                if "Complete" in icsv_line[11]:
                    temp = icsv_line[19].replace("ftp://", "https://")
                    icsv_line[19] = temp
                    species_list.append(icsv_line)
            except KeyError:
                pass
    return species_list

    def calc_size(species_list):
        #calculates the size of genome from location of genome
        species_list2 = []
        i=0
        for line in species_list:
            print(i)
            genome_size = 0
            csv_location = line[19]
            strain = csv_location.split("/")[-1] + "_genomic.fna.gz"
            f = urllib.request.urlopen(csv_location + "/" + strain)
            #zipfile = gzip.open(BytesIO(f.read()))
            zipfile = gzip.open(f)
            for rec in zipfile.readlines():
                keep = bytearray(rec).decode('ascii').strip("\n")
                keep_num = len(keep)
                genome_size = genome_size + keep_num
                #genome_size = sum([len(rec.strip("\n")) for rec in zipfile if ">" not in rec])
            species_list2.append([line[7], str(genome_size)])
            i=i+1


species_list = fetch_all_complete()
species_list2 = calc_size(species_list)

with open("/ebio/abt6_projects9/metagenomic_controlled/data/genome_size/genome_size_ncbi.txt", 'wb') as f:
    for item in species_list2:
        f.write("{}\n".format(item))
'''
#in reality, the above text doesn't have many of the relevant organisms for some reason (such as albugo and hpa). Instead, I went to this website: https://www.ncbi.nlm.nih.gov/genome/browse/#!/overview/ and downloaded the full list of genomes and their sizes. This was done on 21.9.2018

genomes = [line.strip().split(",") for line in open("genomes.csv").readlines()]
genome_dict = {}
for line in genomes:
    if len(line[0].split(" ")) < 2:
        pass
    else:
        try:
            genome_dict[(line[0].split(' ')[0], line[0].split(' ')[1])] = float(line[2])
        except ValueError:
            genome_dict[(line[0].split(' ')[0], line[0].split(' ')[1])] = (line[2])

set_genus = set([line[0] for line in genome_dict.keys()])
genus_dict = {}
for genus in set_genus:
    keep = [genome_dict[key] for key in genome_dict if genus == key[0] and type(genome_dict[key]) == float]
    mean_size = np.mean(keep)
    mean_sd = np.std(keep)
    genus_dict[genus.strip('"')] = [mean_size, mean_sd]

pickle.dump(genus_dict, open("genus_dict.pck", "wb"))
