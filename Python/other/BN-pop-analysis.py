# -*- coding: utf-8 -*-
"""
BadgerNet Population Analysis graphs

TODO:
    - Add gestation at booking histogram (or something else?)
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


custom_params = {"axes.spines.right": False, "axes.spines.top": False}
sns.set_theme(style="ticks", rc=custom_params)

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

plt.rcParams.update({'font.size': 14})

fig_path = "../outputs/figures/"


#%% Load data
data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

#data.loc[data.loc[:,"Ethnicity"] == "Middle_Eastern","Ethnicity"] = "Middle Eastern"
#data.loc[data.loc[:,"EthnicCategory"] == "Any Other ethnic group","EthnicCategory"] = "Other"

#%% ethnicity bar
plt.close("all")

fig = plt.figure(figsize=(7, 10))
gs = fig.add_gridspec(7, 28)

xmax = 30000

ax1 = fig.add_subplot(gs[:, 0:28])
sns.countplot(data = data, y = "Ethnicity Group",
              order = np.unique(data["Ethnicity Group"])[::-1],
              color = sns.color_palette()[0])
ax1.set_ylabel("")
ax1.set_yticklabels(["Asian", "Black", "Middle\nEastern",
                     "Mixed", "Other", "Unknown", "White"][::-1])
#ax.spines['left'].set_position(('data', -1))
#ax1.spines[['right', 'top']].set_visible(False)
offsets = [14, 7, 5, 6, 4, 3, 22]
ax1.set_ylim([-0.4, 6.4])
ax1.set_xlim(0, xmax)
#pallets = ["RdPu", "copper_r","Purples","Reds","Greens","Oranges","Blues"]
pallets = ["Blues","Blues","Blues","Blues","Blues","Blues","Blues"]

for i, ethnicity in enumerate(np.unique(data["Ethnicity Group"])):
    if ethnicity == "White":
        startangle = -85
    else:
        startangle = 0
    
    ax = fig.add_subplot(gs[i,offsets[i]:offsets[i]+5])
    data_i = data[data["Ethnicity Group"] == ethnicity].value_counts("AllEthnicities")
    plt.pie(data_i, labels = data_i.keys(),
            colors = sns.color_palette(pallets[i], len(data_i)),
            textprops = {'fontsize': 8},
            labeldistance = 1.2,
            radius = 0.8,
            startangle = startangle)
    plt.show()
    
# for i in range(-1,7):
#     ax1.fill_between([0, xmax], [i+0.5, i+0.5], 
#                      [i+1.5, i+1.5], color = "gray", 
#                      alpha = 0.1*(i%2!=0))

plt.savefig(fig_path + "badger_pop/ethnicity.pdf", bbox_inches = "tight")

#%% ethnicity bar - horizontal
plt.close("all")

data2 = data.copy()
#data2 = data2.replace("Black African", "Black\nAfrican")
data2 = data2.replace("Black Caribbean", "Black\nCaribbean")
data2 = data2.replace("Middle Eastern", "Middle\nEastern")
#data2 = data2.replace("White and Black African", "White and\nBlack African")
#data2 = data2.replace("White and Black Caribbean", "White and\nBlack Caribbean")
#data2 = data2.replace("White and Asian", "White and\nAsian")
data2 = data2.replace("Declined to answer", "Declined to\nanswer")
data2 = data2.replace("Irish", "Irish\n")

fig = plt.figure(figsize=(10, 5))
gs = fig.add_gridspec(28, 7)

ymax = 25000

ax1 = fig.add_subplot(gs[0:28, :])
sns.countplot(data = data2, x = "Ethnicity Group",
              order = np.unique(data["Ethnicity Group"]),
              #color = sns.color_palette()[0]
              )
ax1.set_xlabel("")
ax1.set_ylabel("Number of Births")
ax1.set_xticklabels(["Asian", "Black", "Middle\nEastern",
                     "Mixed", "Other", "Unknown", "White"])
#ax.spines['left'].set_position(('data', -1))
#ax1.spines[['right', 'top']].set_visible(False)
offsets = [8, 18, 22, 19, 23, 23, 0]
startangles = [-20,-45,45,10,0,-150,-10]
ax1.set_xlim([-0.4, 6.4])
ax1.set_ylim(0, ymax)
pallets = ["RdPu", "copper_r","Purples","Reds","Greens","Oranges","Blues"]
#pallets = ["Blues","Blues","Blues","Blues","Blues","Blues","Blues"]

for i, ethnicity in enumerate(np.unique(data2["Ethnicity Group"])):
    startangle = startangles[i]
    
    ax = fig.add_subplot(gs[offsets[i]:offsets[i]+5,i])
    data_i = data2[data2["Ethnicity Group"] == ethnicity].value_counts("AllEthnicities")
    plt.pie(data_i, labels = data_i.keys(),
            colors = sns.color_palette(pallets[6-i], len(data_i)),
            textprops = {'fontsize': 8},
            labeldistance = 1.2,
            radius = 0.9,
            startangle = startangle)
    plt.show()
    
# for i in range(-1,7):
#     ax1.fill_between([0, xmax], [i+0.5, i+0.5], 
#                      [i+1.5, i+1.5], color = "gray", 
#                      alpha = 0.1*(i%2!=0))

plt.savefig(fig_path + "badger_pop/ethnicity-h-2.pdf", bbox_inches = "tight")


#%% Ethnicty and IMD

plt.rcParams.update({'font.size': 14})


data_imd = data
#data_imd["Index of Multiple Deprivation Decile_v2"] = data_imd["Index of Multiple Deprivation Decile_v2"].astype(int)
#data_imd["IMD Quntile"] = np.floor((data_imd["Index of Multiple Deprivation Decile_v2"]+1)/2)

eth_imd_piv = data_imd.pivot_table(values = "MthYr", index = "IMD Quintile - ALL", columns = "Ethnicity Group", aggfunc='count')

fig = plt.figure(figsize=(8, 8))
gs = fig.add_gridspec(8, 8)

ax1 = fig.add_subplot(gs[2:8, :6])
sns.heatmap(eth_imd_piv, annot=True, fmt="d", linewidths=.5, 
            ax=ax1, cmap = "Blues", cbar=False)

#ax1.set_yticks([1,2,3,4,5])

ax1.set_yticklabels(ax1.get_yticks(), rotation = 0)
ax1.set_yticklabels(["1\nMost\ndeprived","2","3","4","5\nLeast\ndeprived"])

ax1.set_xticklabels(ax1.get_xticks(), rotation = 0)
ax1.set_xticklabels(["Asian", "Black", "Middle\nEastern",
                     "Mixed", "Other", "Unknown", "White"])
ax1.set_xlabel("")
ax1.set_ylabel("IMD Quintile", size = 14)

ax2 = fig.add_subplot(gs[:2, :6])
sns.countplot(data_imd, x = "Ethnicity Group", 
              color = sns.color_palette()[0],
              order = np.unique(data_imd["Ethnicity Group"]))
ax2.set_xticks([])
ax2.set_xlabel("")
ax2.set_ylabel("Total Count", size = 12)

ax3 = fig.add_subplot(gs[2:, 6:])
sns.countplot(data_imd, y = "IMD Quintile - ALL",
              color = sns.color_palette()[0],
              order = [1,2,3,4,5])
ax3.set_yticks([])
ax3.set_ylabel("")

ax3.set_xlabel("Total Count", size = 12)


for ax in [ax1, ax2, ax3]:
    if type(ax.get_yticklabels()) == list:
        ax.set_yticklabels(ax.get_yticklabels(), size = 12)
    if type(ax.get_xticklabels()) == list:
        ax.set_xticklabels(ax.get_xticklabels(), size = 12)

plt.savefig(fig_path + "badger_pop/ethnicity_IMD.pdf", bbox_inches = "tight")

#%% Maternal age
fig = plt.figure(figsize = (8,4))
ax1 = fig.add_subplot(111)
sns.boxplot(data=data[data["Age"] != "Other"], 
             y = "Age", 
             x = "Ethnicity",
             order = np.unique(data_imd["Ethnicity"]),
             color = sns.color_palette()[0])
ax1.set_xticklabels(["Asian", "Black", "Middle\nEastern",
                     "Mixed", "Other", "Unknown", "White"])
plt.savefig(fig_path + "mother_age.pdf", bbox_inches = "tight")


#%% Birth weight and gestational age

data2 = data[(data["Age"] != "Other")*(data["GestationAtDeliveryWeeks"] != "Other")]

# jitter values
data2["GestationAtDeliveryWeeks"] = data2["GestationAtDeliveryWeeks"]+np.random.rand(len(data2))-0.5
data2["Age"] = data2["Age"]+np.random.rand(len(data2))-0.5

sns.jointplot(data=data2, 
              x="Age", y="GestationAtDeliveryWeeks",
              hue = "BirthWeight_Grams <2500", alpha =0.2)

#%% Outcome table

Counts = data[["Deliveries under 37 weeks","BirthWeight_Grams <2500"]].value_counts()
print(Counts)

