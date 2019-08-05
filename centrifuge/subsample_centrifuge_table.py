#!/usr/bin/python3

'''The point of this script is to take a centrifuge count table and to subsample for each individual a user - defined number of reads'''

import sys
import pandas as pd
from random import choice
import numpy as np
from itertools import chain


def downsample(df, N):
    for sample in df.columns:
        prob = df[sample] / sum(df[sample])
        df[sample] = list(chain.from_iterable(np.random.multinomial(n=N, pvals=prob, size=1)))
    # df = df[df['count'] != 0]
    return df



# tab_file = sys.argv[1]
tab_file = "centrifuge_metagenome_table.txt"
num_reads = int(sys.argv[2])

cent_pd = pd.read_csv(tab_file, index_col=0, sep="\t")


subsampled = downsample(cent_pd, num_reads)

subsampled.to_csv(tab_file.strip("txt") + str(num_reads) + "reads.txt")
