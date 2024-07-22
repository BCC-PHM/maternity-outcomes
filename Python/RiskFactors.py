# -*- coding: utf-8 -*-
"""
Risk factor analysis - Who has highest rates of different risk factors?
"""

import seaborn as sns
import pandas as pd
import EquiPy.Matrix as Mat

import matplotlib.pyplot as plt
import numpy as np

custom_params = {"axes.spines.right": False, "axes.spines.top": False}
sns.set_theme(style="ticks", rc=custom_params)

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

fig_path = "../outputs/figures/inequality_matricies/"

def conf_int(p, n):
    return 1.96 * np.sqrt(p * (1-p) / n)

#%% Load data
data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

data["Ethnicity Group"] = data["Ethnicity Group"].replace('Middle Eastern', 'Middle\nEastern')

#%% Prepare dependent variables 

# Convert to boolean arrays
data['Financial/Housing\nIssue(s)'] = data['Financial/Housing Issues'] == "Yes" 
data["Social Services\nInvolved"] = data["SocialServicesInvolvement"] == "Yes"  
data["Smoking at Birth"] = data["SmokingAtDelivery"] == "Yes" 
data["Substance Abuse"] = data["substanceAbuse"] == "Yes" 
data["Mother Aged 40+"] = data["Age Group"] == "40+" 
data["Teenage Pregnancy"] = (data["Age"] < 18) & (data["Age"] >= 12)
data["Breastfeed at Initiation"] = data["BreastfeedAtInitiation"] == "Yes"
data["Sensory/Physical\nDisability"] = data["sensoryAndPhysicalDis"] == "Yes"
data["Twins"] = data["NumberOfBabies"] == 2 
data["Mental Health\nIssue(s)"] = data["MentalHealth"] == "Yes" 
data["Obesity"] = data["BMI>35"] == "Yes" 
data["Gestational Diabetes"] = data["Gestational_Diabetes"] == "Yes" 
data["Folic Acid Taken"] = data["Folic Acid Taken"] == "Yes"
data["Early Booking"] = data["Early booking"] == "Yes" 
data["Late Booking"] = data["Late booking"] == "Yes" 
data["Consanguineous\nUnion"] = data["Consanguineous_Relationship"] == "Yes"
data["> 4 Missed Appointments"] = data["> 4 missed apts"] == "Yes"

dep_vars = [
    "Financial/Housing\nIssue(s)",
    "Social Services\nInvolved",
    "Smoking at Birth",
    "Substance Abuse",
    "Teenage Pregnancy",
    "Mother Aged 40+",
    "Breastfeed at Initiation",
    "Sensory/Physical\nDisability",
    "Twins",
    "Mental Health\nIssue(s)",
    "Obesity",
    "Gestational Diabetes",
    "Folic Acid Taken",
    "Early Booking",
    "Late Booking",
    "> 4 Missed Appointments",
    "Consanguineous\nUnion",
    ]

#%% Create all inequality matricies

letters = ["A", "B", "C", "D", "E", "F"]

for i, var in enumerate(dep_vars):    
    fig_num = i//6 + 1
    letter = letters[i-6*(fig_num - 1)]
    print("\n" + "-"*20)
    print(i, letter, var.replace("\n", ""))
    
    n = np.sum(data[var])
    p = np.mean(data[var])
    total_average = 100*p
    print("\t Av = {:.1f} +/- {:.1f} %".format(total_average, 100*conf_int(p, n)))
    
    perc_pivot = Mat.get_pivot(
            data, 
            var,
            eth_col = "Ethnicity Group", 
            IMD_col = "IMD Quintile - ALL",
            mode="percentage"
            )

    count_pivot = Mat.get_pivot(
            data, 
            eth_col = "Ethnicity Group", 
            IMD_col = "IMD Quintile - ALL",
            mode="count"
            )
    
    eth_n = np.sum(count_pivot, axis = 0)
    eth_p = np.sum(perc_pivot/100*count_pivot, axis = 0)/np.sum(count_pivot, axis = 0)
    eth_av = pd.DataFrame({
        "%" : np.round(100*eth_p,1),
        "+/-" : np.round(100*conf_int(eth_p, eth_n), 1)
                  }).sort_values("%", ascending=False)
    
    imd_n = np.sum(count_pivot, axis = 1)
    imd_p = np.sum(perc_pivot/100*count_pivot, axis = 1)/np.sum(count_pivot, axis = 1)
    imd_av = pd.DataFrame({
        "%" : np.round(100*imd_p,1),
        "+/-" : np.round(100*conf_int(imd_p, imd_n), 1)
                  }).sort_values("%", ascending=False)    
    
    print(eth_av)
    print()
    print(imd_av)   
    
    fig = Mat.inequality_map(count_pivot, 
                       perc_pivot,
                       title = var,
                       ttest = True,
                       letter=letter)

    save_name = fig_path + "IneqMat-{}-{}.pdf".format(fig_num, letter)
    
    fig.savefig(save_name, bbox_inches = "tight")

plt.close("all")
