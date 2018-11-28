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
from matplotlib.lines import Line2D

'''this script takes the output tables from recalibrate_metagenome.py and will generate stacked barplots of content
USAGE EXAMPLE
./visualize_metagenome -genus_meta_table genus_recalibrate -family_meta_table family_recalibrate

'''
def subset_limit(meta_file, limit):
        max_val = meta_file.max(skipna = True, axis=0)>0.1
        tot=meta_file[[rec for rec in max_val.index if max_val.loc[rec]==True]]
        return tot





genus_file = sys.argv[1]
family_file = sys.argv[2]
print(family_file)
genus_file = "meta_genus_corrected_per_plant.csv"
family_file="meta_family_corrected_per_plant.csv"
genus = pd.read_csv(genus_file, index_col=0).transpose()
family = pd.read_csv(family_file, index_col=0).transpose()
# sort genus on
# or with a pandas dataframe
# matplotlib.style.use('ggplot')
# https://pstblog.com/2016/10/04/stacked-charts



'''


fig, ax = plt.subplots()
fig.set_size_inches(37, 21)
#months = df['Month'].drop_duplicates()
#margin_bottom = np.zeros(len(['Year'].drop_duplicates()))
colors = sns.color_palette("Paired", n_colors=len(genus.index))
keep_legend = genus[genus.sum().sort_values(ascending=False).index]
custom_legend = [Line2D([0], [0], color=colors[0], lw=4),
                 Line2D([0], [0], color=colors[1], lw=4),
                 Line2D([0], [0], color=colors[2], lw=4),
                 Line2D([0], [0], color=colors[3], lw=4),
                 Line2D([0], [0], color=colors[4], lw=4),
                 Line2D([0], [0], color=colors[5], lw=4),
                 Line2D([0], [0], color=colors[6], lw=4),
                 Line2D([0], [0], color=colors[7], lw=4),
                 Line2D([0], [0], color=colors[8], lw=4),
                 Line2D([0], [0], color=colors[9], lw=4)]
the_plot = keep_legend.plot.bar(stacked=True, color=colors, figsize=(10, 7), width=0.95)
# plt.show()
the_plot.legend(custom_legend, keep_legend.columns[0:9])
#fig.legend(loc=7, bbox_to_anchor= (1.2, 0.5))
# fig.tight_layout()
# fig.subplots_adjust(right=0.75)
plt.xticks(fontsize=8, rotation=90)
plt.ylabel("Proportion of genome covered per A. thaliana genome")
plt.savefig('genus_barplot.pdf', bbox_inches="tight")
'''

fig, ax = plt.subplots()
fig.set_size_inches(37, 21)
#months = df['Month'].drop_duplicates()
#margin_bottom = np.zeros(len(['Year'].drop_duplicates()))
colors = sns.color_palette("Paired", n_colors=len(family.index))
keep_legend = family[family.sum().sort_values(ascending=False).index]
custom_legend = [Line2D([0], [0], color=colors[0], lw=4),
                 Line2D([0], [0], color=colors[1], lw=4),
                 Line2D([0], [0], color=colors[2], lw=4),
                 Line2D([0], [0], color=colors[3], lw=4),
                 Line2D([0], [0], color=colors[4], lw=4),
                 Line2D([0], [0], color=colors[5], lw=4),
                 Line2D([0], [0], color=colors[6], lw=4),
                 Line2D([0], [0], color=colors[7], lw=4),
                 Line2D([0], [0], color=colors[8], lw=4),
                 Line2D([0], [0], color=colors[9], lw=4)]
the_plot = keep_legend.plot.bar(stacked=True, color=colors, figsize=(10, 7), width=0.95)
# plt.show()
the_plot.legend(custom_legend, keep_legend.columns[0:19])
#fig.legend(loc=7, bbox_to_anchor= (1.2, 0.5))
# fig.tight_layout()
# fig.subplots_adjust(right=0.75)
plt.xticks(fontsize=8, rotation=90)
plt.ylabel("Proportion of genome covered per A. thaliana genome")
plt.savefig('family_barplot.pdf', bbox_inches="tight")
