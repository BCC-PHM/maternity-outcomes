# -*- coding: utf-8 -*-
"""
domestic abuse

- Smoking
- Missed antenatal appointments
- 
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

custom_params = {"axes.spines.right": False, "axes.spines.top": False}
sns.set_theme(style="ticks", rc=custom_params)

fig_path = "../outputs/figures/"

def inequality_map(data, 
                   column, 
                   eth_col = "Ethnicity", 
                   IMD_col = "IMD Quintile",
                   agg="mean",
                   fmt=".1f"):
    
    
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
                ax=ax1, cmap = "Blues", cbar=False)

    ax1.set_yticklabels(ax1.get_yticks(), rotation = 0)
    ax1.set_yticklabels(["1\nMost\ndeprived","2","3","4","5\nLeast\ndeprived"])

    ax1.set_xticklabels(ax1.get_xticks(), rotation = 0)
    ax1.set_xticklabels(["Asian", "Black", "Middle\nEastern",
                         "Mixed", "Other", "Unknown", "White"])

    ax2 = fig.add_subplot(gs[:2, :6])
    sns.barplot(data, x = eth_col, y = agg_col,
                  color = sns.color_palette()[0],
                  order = np.unique(data[eth_col]),
                  estimator = agg)
    ax2.set_xticks([])
    ax2.set_xlabel("")


    ax3 = fig.add_subplot(gs[2:, 6:])
    sns.barplot(data, y = IMD_col,
                x = agg_col,
                color = sns.color_palette()[0],
                order = [1,2,3,4,5],orient="h",
                estimator = agg
                )

    ax3.set_yticks([])
    ax3.set_ylabel("")
    return fig

def compare_columns(data, colA, colB, 
                    positive = True,
                    inc_N = True,
                    inc_total = False):
    counts = data[[colA, colB]].value_counts().reset_index()
    A_pos_count = sum(counts[0][counts[colA]==positive])
    A_rate = 100*A_pos_count/sum(counts[0])

    AB_pos_count = sum(counts[0][(counts[colA] == positive)*(counts[colB] == positive)])

    if inc_total:
        print("Total of {:.3}% {} have `{}`".format(A_rate, 
                                                 "(n={})".format(inc_N*str(A_pos_count)),
                                                 colA))
    if sum(counts[0][counts[colB] == positive]) > 0:
        A_with_B_rate = 100*AB_pos_count/sum(counts[0][counts[colB] == positive])
        print("{:.3}% {} with `{}` have `{}`".format(A_with_B_rate, 
                                                 "(n={})".format(inc_N*str(AB_pos_count)),
                                                 colB, colA))
    else:
        print("No cases with both `{}` and  `{}`".format(colB, colA))


#%% Load data
data = pd.read_excel("../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
                     sheet_name = 0)

data.loc[data.loc[:,"Ethnicity"] == "Middle_Eastern","Ethnicity"] = "Middle Eastern"
data.loc[data.loc[:,"EthnicCategory"] == "Any Other ethnic group","EthnicCategory"] = "Other"

data.loc[:,"SmokingAtDelivery"] = data["SmokingAtDelivery"] == "Yes"


# remove unknown IMD
data = data[data['Index of Multiple Deprivation Decile_v2'] != "No Match"]
data['Index of Multiple Deprivation Decile_v2'] = data['Index of Multiple Deprivation Decile_v2'].astype(int)
data["IMD Quintile"] = np.floor((data['Index of Multiple Deprivation Decile_v2'] + 1)/2)

# Remove 1 case with NA missed appointments
data.loc[data.loc[:,"MissedANAppointments"] == "No","MissedANAppointments"] = 0
data = data.dropna(subset=["MissedANAppointments"])

#%% By IMD and Ethnicity
data["Domestic Abuse"] = data["DomesticAbuse"] == "Yes"

                                       
fig = inequality_map(data, "Domestic Abuse", 
                   eth_col = "Ethnicity", 
                   IMD_col = "IMD Quintile",
                   agg="mean",
                   fmt=".1f")

fig.savefig(fig_path + "eth_IMD_DualDiag_domesticAbuse.png", bbox_inches = "tight")


#%% Other risk factors
data["Drug/Alcohol Abuse"] = np.logical_or(
    data["DrugAbuse"] == "Yes",
     data["AlcoholAbuse"] == "Yes"
     )

data["Dual diagnosis"] = np.logical_and(
    data["Drug/Alcohol Abuse"],
     data["MentalHealth"] == "Yes"
     )

compare_columns(data, "Domestic Abuse", "Drug/Alcohol Abuse", inc_total=True)

compare_columns(data, "DomesticAbuse", "MentalHealth", positive = "Yes")

compare_columns(data, "Domestic Abuse", "Dual diagnosis")

compare_columns(data, "DomesticAbuse", "LearningDisabilities", positive = "Yes")

compare_columns(data, "DomesticAbuse", "Unsupported", positive = "Yes")

compare_columns(data, "DomesticAbuse", "Citizenship", positive = "Yes")

#%% Late booking
print("-"*10)

late_booking = 19

data["Late Booking"] = (data["GestationAtBookingWeeks"] > late_booking) * \
(data["GestationAtBookingWeeks"] < data["GestationAtDeliveryWeeks"])

compare_columns(data, "Late Booking", "Domestic Abuse", inc_total=True)

print("(Late booking defined as booking after 19 weeks of gestation)")

#%% missed appointments

print("-"*10)
data["MissedANAppointments"] = data["MissedANAppointments"].astype(int)
data["> 4 missed apts"] = data["MissedANAppointments"] > 4

compare_columns(data, "> 4 missed apts", "Domestic Abuse", inc_total=True)

#%% Low birth weight

print("-"*10)
compare_columns(data, "LowBirthWeight", "Domestic Abuse", inc_total=True)

#%% Low birth weight

print("-"*10)
compare_columns(data, "Premature", "Domestic Abuse", inc_total=True)