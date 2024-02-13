# -*- coding: utf-8 -*-
"""
Risk factor analysis - Who has highest rates of different risk factors?
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

fig_path = "../outputs/figures/inequality_matricies/"

def inequality_map(data, 
                   column, 
                   color = "Purples",#"Reds",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   agg="mean",
                   fmt=".1f",
                   letter = "A"):
    cmap = color
    if color == "Blues":
        bar_col = "tab:blue"
    elif color == "Reds":
        bar_col = "tab:red"
    elif color == "RdPu":
        bar_col = "#E12184"
    elif color == "Purples":
        bar_col = "tab:purple"
    else:
        bar_col = "Gray"
    
    if agg=="mean":
        multiply = 100
        agg_col = "{} %".format(column)
    elif agg=="sum":
        agg_col = "Total number\n{}".format(column)
        multiply = 1
    else:
        agg_col = "agg val"
        multiply = 1
        
    data[agg_col] = multiply*data[column]

    eth_imd_piv = data.pivot_table(values = column, index = IMD_col, 
                                       columns = eth_col, aggfunc= agg)

    fig = plt.figure(figsize=(8, 8))
    gs = fig.add_gridspec(8, 8)

    ax1 = fig.add_subplot(gs[2:8, :6])
    sns.heatmap(multiply*eth_imd_piv, annot=True, fmt = fmt, linewidths=.5, 
                ax=ax1, cmap = cmap, cbar=False)

    ax1.set_yticklabels(ax1.get_yticks(), rotation = 0)
    ax1.set_yticklabels(["1\nMost\ndeprived","2","3","4","5\nLeast\ndeprived"])
    
    ax1.set_xticklabels(ax1.get_xticks(), rotation = 0)
    ax1.set_xticklabels(["Asian", "Black", "Middle\nEastern",
                         "Mixed", "Other", "Unknown", "White"])
    ax1.set_ylabel("IMD Quintile")
    
    ax2 = fig.add_subplot(gs[:2, :6])
    bar1 = sns.barplot(data, x = eth_col, y = agg_col,
                  color = bar_col,
                  order = np.unique(data[eth_col]),
                  estimator = agg)
    bar1.get_lines()[0].get_data()
    ax2.set_xticks([])
    ax2.set_xlabel("")


    ax3 = fig.add_subplot(gs[2:, 6:])
    sns.barplot(data, y = IMD_col,
                x = agg_col,
                color = bar_col,
                order = [1,2,3,4,5],orient="h",
                estimator = agg
                )

    ax3.set_yticks([])
    ax3.set_ylabel("")
    
    ax1.annotate(letter, (0.82, 0.82), xycoords='figure fraction',
                 size = 22)
    
    return fig

def compare_columns(data, colA, colB):
    counts = data[[colA, colB]].value_counts().reset_index()
    A_rate = 100*sum(counts[0][counts[colA]==True])/sum(counts[0])

    A_with_B_rate = 100*counts[0][(counts[colA] == True)*(counts[colB] == True)]/sum(counts[0][counts[colB] == True])
    A_with_B_rate = A_with_B_rate.values[0]
    print("Total of {:.3}% have `{}`".format(A_rate, colA))
    print("{:.3}% with `{}` have `{}`".format(A_with_B_rate, colB, colA))

#compare_columns(data2, "Domestic Abuse", "Drug/Alcohol Abuse")

#%% Load data

data2 = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')
#%% Financial/Housing Problems - A

data2['Financial/Housing\nIssue(s)'] = data2['Financial/Housing Issues'] == "Yes"
fig = inequality_map(data2, 'Financial/Housing\nIssue(s)', 
                   agg="mean",
                   fmt=".1f",
                   letter = "A")

fig.savefig(fig_path + "eth_IMD_HousingFinancial.pdf", bbox_inches = "tight")

#%% Social Services - B
data2["Social Services\nInvolved"] = data2["SocialServicesInvolvement"] == "Yes"

                                       
fig = inequality_map(data2, "Social Services\nInvolved", 
                   agg="mean",
                   fmt=".1f"
                   , letter = "B")

fig.savefig(fig_path + "eth_IMD_Social_Services.pdf", bbox_inches = "tight")

#%% Smoking - C
data2["Smoking at Birth"] = data2["SmokingAtDelivery"] == "Yes"
fig = inequality_map(data2, 
                     column = "Smoking at Birth", 
                     agg="mean",
                     fmt=".1f",
                     letter = "C")

fig.savefig(fig_path + "eth_IMD_smoking.pdf", bbox_inches = "tight")

#%% Substance Abuse - D
data2["Substance Abuse"] = data2["substanceAbuse"] == "Yes"
                                       
fig = inequality_map(data2, "Substance Abuse", 
                   agg="mean",
                   fmt=".1f",
                   letter = "D")

fig.savefig(fig_path + "eth_IMD_substanceAbuse.pdf", bbox_inches = "tight")


#%% Older Mother (40+) - E

data2["Mother Aged 40+"] = data2["Age Group"] == "40+"
fig = inequality_map(data2, "Mother Aged 40+", 
                   agg="mean",
                   fmt=".1f",
                   letter = "E")

fig.savefig(fig_path + "eth_IMD_40_plus.pdf", bbox_inches = "tight")


#%% Breast fed at initiation - F
data2["Breastfeed at Initiation"] = data2["BreastfeedAtInitiation"] == "Yes"
fig = inequality_map(data2, "Breastfeed at Initiation", 
                   agg="mean",
                   fmt=".1f",
                   letter = "F")

fig.savefig(fig_path + "eth_IMD_breastfeed.pdf", bbox_inches = "tight")



#%% Sensory and Physical Disability - A

data2["Sensory/Physical\nDisability"] = data2["sensoryAndPhysicalDis"] == "Yes"
fig = inequality_map(data2, "Sensory/Physical\nDisability", 
                   agg="mean",
                   fmt=".1f",
                   letter = "A")

fig.savefig(fig_path + "eth_IMD_disability.pdf", bbox_inches = "tight")


#%% Twins - B

data2["Twins"] = data2["NumberOfBabies"] == 2
fig = inequality_map(data2, "Twins", 
                   agg="mean",
                   fmt=".1f",
                   letter = "B")

fig.savefig(fig_path + "eth_IMD_Twins.pdf", bbox_inches = "tight")

#%% Mental Health - C

data2["Mental Health\nIssue(s)"] = data2["MentalHealth"] == "Yes"
fig = inequality_map(data2, "Mental Health\nIssue(s)", 
                   agg="mean",
                   fmt=".1f",
                   letter = "C")

fig.savefig(fig_path + "eth_IMD_MentalHealth.pdf", bbox_inches = "tight")

#%% Obesity - D

data2["Obesity"] = data2["BMI>35"] == "Yes"
fig = inequality_map(data2, "Obesity", 
                   agg="mean",
                   fmt=".1f",
                   letter = "D")

fig.savefig(fig_path + "eth_IMD_Obesity.pdf", bbox_inches = "tight")

#%% Gestational Diabetes - E
data2["Gestational Diabetes"] = data2["Gestational_Diabetes"] == "Yes"
fig = inequality_map(data2, "Gestational Diabetes", 
                   agg="mean",
                   fmt=".1f",
                   letter = "E")

fig.savefig(fig_path + "eth_IMD_GestDiab.pdf", bbox_inches = "tight")

#%% Folic Acid Taken - F
data2["Folic Acid Taken"] = data2["Folic Acid Taken"] == "Yes"
fig = inequality_map(data2, "Folic Acid Taken", 
                   agg="mean",
                   fmt=".1f",
                   letter = "F")

fig.savefig(fig_path + "eth_IMD_FolicAcid.pdf", bbox_inches = "tight")


#%% Late booking - A

late_booking = 19

data2["Late Booking"] = data2["Late booking"] == "Yes"

fig = inequality_map(data2, "Late Booking", 
                   agg="mean",
                   fmt=".1f",
                   letter = "A")

fig.savefig(fig_path + "eth_IMD_latebooking.pdf", bbox_inches = "tight")

#%% Missed more than 4 apts - B

data3 = data2.copy()
data3["> 4 Missed Appointments"] = data3["> 4 missed apts"] == "Yes"

fig = inequality_map(data3, "> 4 Missed Appointments", 
                   agg="mean",
                   fmt=".1f",
                   letter = "B")

fig.savefig(fig_path + "eth_IMD_missedApts.pdf", bbox_inches = "tight")

#%% Consanguineous_Relationship - C
data2["Consanguineous\nUnion"] = data2["Consanguineous_Relationship"] == "Yes"

                                       
fig = inequality_map(data2, "Consanguineous\nUnion", 
                   agg="mean",
                   fmt=".1f",
                   letter = "C")

fig.savefig(fig_path + "eth_IMD_consang.pdf", bbox_inches = "tight")