import matplotlib as mpl
mpl.use('Agg')
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc
import pandas as pd
import argparse
import sys
import seaborn as sns
from sklearn.decomposition import PCA

'''this script takes the output tables from recalibrate_metagenome.py and will generate stacked barplots of content
USAGE EXAMPLE
./visualize_metagenome -genus_meta_table genus_recalibrate -family_meta_table family_recalibrate

'''

genus_file = sys.argv[0]
family_file = sys.argv[1]
genus = pd.read_csv(genus_file, index_col=0).transpose()

#sort genus on
# or with a pandas dataframe
# matplotlib.style.use('ggplot')
# https://pstblog.com/2016/10/04/stacked-charts


fig, ax = plt.subplots()
#months = df['Month'].drop_duplicates()
#margin_bottom = np.zeros(len(['Year'].drop_duplicates()))
colors = sns.color_palette("cubehelix", n_colors=len(genus.index))
#pivot_df = d.pivot(index='Year', columns='Month', values='Value')
# Note: .loc[:,['Jan','Feb', 'Mar']] is used here to rearrange the layer ordering
genus.plot.bar(stacked=True, color=colors, figsize=(10, 7), width=0.95)
# plt.show()
fig.legend(loc=7, bbox_to_anchor= (1.2, 0.5))
#fig.tight_layout()
#fig.subplots_adjust(right=0.75)
plt.ylabel("Proportion of genome covered per A. thaliana genome")
plt.savefig('genus_barplot.pdf', bbox_inches="tight")

# PCA
'''
pca = PCA(n_components=5)
pca.fit(df)
'''



c = ["blue", "purple", "red", "green", "pink"]
for i, g in enumerate(genus):
    ax = sns.barplot(data=genus[g],
                     #hue="Name",
                     color=colors,
                     zorder=-i,
                     edgecolor="k")
ax.legend_.remove() # remove the redundant legends
