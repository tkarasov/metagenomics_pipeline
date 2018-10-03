import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc
import pandas as pd
import matplotlib
import argparse
import sys
import seaborn as sns

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


'''
#y-axis in bold
rc('font', weight = 'bold')

# Values of each group
bars1 = [12, 28, 1, 8, 22]
bars2 = [28, 7, 16, 4, 10]
bars3 = [25, 3, 23, 25, 17]
 
# Heights of bars1 + bars2 (TO DO better)
bars = [40, 35, 17, 12, 32]
 
# The position of the bars on the x-axis
#r = [0,1,2,3,4]
r = np.arange(len(bars))
 
# Names of group and bar width
names = ['A','B','C','D','E']
barWidth = 1
 
# Create brown bars
plt.bar(r, bars1, color='#7f6d5f', edgecolor='white', width=barWidth)
# Create green bars (middle), on top of the firs ones
plt.bar(r, bars2, bottom=bars1, color='#557f2d', edgecolor='white', width=barWidth)
# Create green bars (top)
plt.bar(r, bars3, bottom=bars, color='#2d7f5e', edgecolor='white', width=barWidth)
 
# Custom X axis
plt.xticks(r, names, fontweight='bold')
plt.xlabel("group")
plt.legend((p1[0], p2[0]), ('Men', 'Women'))

# Show graphic
plt.show()
'''
