import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc
import pandas as pd
import matplotlib
import argparse
import sys
import seaborn as sns
from sklearn.decomposition import PCA

'''this script takes the output tables from recalibrate_metagenome.py and will generate stacked barplots of content
USAGE EXAMPLE
./visualize_metagenome -genus_meta_table genus_recalibrate -family_meta_table family_recalibrate 

'''

genus = sys.argv[0]
family = sys.argv[1]


# or with a pandas dataframe
# matplotlib.style.use('ggplot')
# https://pstblog.com/2016/10/04/stacked-charts
data = [[2000, 2000, 2000, 2001, 2001, 2001, 2002, 2002, 2002],
        ['Jan', 'Feb', 'Mar', 'Jan', 'Feb', 'Mar', 'Jan', 'Feb', 'Mar'],
        [1, 2, 3, 4, 5, 6, 7, 8, 9]]

rows = list(zip(data[0], data[1], data[2]))
headers = ['Year', 'Month', 'Value']
df = pd.DataFrame(rows, columns=headers)

df


fig, ax = plt.subplots(figsize=(10, 7))
months = df['Month'].drop_duplicates()
margin_bottom = np.zeros(len(df['Year'].drop_duplicates()))
colors = sns.color_palette("cubehelix", n_colors=len(df.columns))
months = df['Month'].drop_duplicates()
margin_bottom = np.zeros(len(df['Year'].drop_duplicates()))
pivot_df = df.pivot(index='Year', columns='Month', values='Value')
# Note: .loc[:,['Jan','Feb', 'Mar']] is used here to rearrange the layer ordering
pivot_df.loc[:, ['Jan', 'Feb', 'Mar']].plot.bar(stacked=True, color=colors, figsize=(10, 7), width=0.9)
# plt.show()

plt.savefig('genus_barplot.pdf')

# PCA
'''
pca = PCA(n_components=5)
pca.fit(df)
'''
