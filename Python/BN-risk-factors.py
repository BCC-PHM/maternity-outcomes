# -*- coding: utf-8 -*-
"""
Risk factor analysis - Who has highest rates of different risk factors?
"""

import seaborn as sns
import pandas as pd
import sys

AF_path = r"C:\Users\TMPCDDES\OneDrive - Birmingham City Council\Documents\Main work\MiscCode\EquiPy"
if not AF_path in sys.path:
    sys.path.append(AF_path)
import EquiPy.Matrix as Mat

custom_params = {"axes.spines.right": False, "axes.spines.top": False}
sns.set_theme(style="ticks", rc=custom_params)

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

fig_path = "../outputs/figures/inequality_matricies/"

# def compare_columns(data, colA, colB):
#     counts = data[[colA, colB]].value_counts().reset_index()
#     A_rate = 100*sum(counts[0][counts[colA]==True])/sum(counts[0])

#     A_with_B_rate = 100*counts[0][(counts[colA] == True)*(counts[colB] == True)]/sum(counts[0][counts[colB] == True])
#     A_with_B_rate = A_with_B_rate.values[0]
#     print("Total of {:.3}% have `{}`".format(A_rate, colA))
#     print("{:.3}% with `{}` have `{}`".format(A_with_B_rate, colB, colA))


#%% Load data

data2 = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

#%% Financial/Housing Problems - A

data2['Financial/Housing\nIssue(s)'] = data2['Financial/Housing Issues'] == "Yes"
fig = Mat.inequality_map(data2, 'Financial/Housing\nIssue(s)', 
                         eth_col = "Ethnicity Group", 
                         IMD_col = "IMD Quintile - ALL",
                         agg="mean",
                         letter = "A",
                         ttest = True)

fig.savefig(fig_path + "eth_IMD_HousingFinancial.pdf", bbox_inches = "tight")

#%% Social Services - B
data2["Social Services\nInvolved"] = data2["SocialServicesInvolvement"] == "Yes"

                                       
fig = Mat.inequality_map(
    data2, 
    "Social Services\nInvolved", 
    agg="mean",
    letter = "B",
    eth_col = "Ethnicity Group", 
    IMD_col = "IMD Quintile - ALL",
    ttest = True
    )

fig.savefig(fig_path + "eth_IMD_Social_Services.pdf", bbox_inches = "tight")

#%% Smoking - C
data2["Smoking at Birth"] = data2["SmokingAtDelivery"] == "Yes"
fig =  Mat.inequality_map(data2, 
                     column = "Smoking at Birth", 
                     agg="mean",
                     letter = "C",
                     eth_col = "Ethnicity Group", 
                     IMD_col = "IMD Quintile - ALL",
                     ttest = True)

fig.savefig(fig_path + "eth_IMD_smoking.pdf", bbox_inches = "tight")

#%% Substance Abuse - D
data2["Substance Abuse"] = data2["substanceAbuse"] == "Yes"
                                       
fig = Mat.inequality_map(data2, "Substance Abuse", 
                   agg="mean",
                   letter = "D",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_substanceAbuse.pdf", bbox_inches = "tight")


#%% Older Mother (40+) - E

data2["Mother Aged 40+"] = data2["Age Group"] == "40+"
fig = Mat.inequality_map(data2, "Mother Aged 40+", 
                   agg="mean",
                   letter = "E",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_40_plus.pdf", bbox_inches = "tight")


#%% Breast fed at initiation - F
data2["Breastfeed at Initiation"] = data2["BreastfeedAtInitiation"] == "Yes"
fig = Mat.inequality_map(data2, "Breastfeed at Initiation", 
                   agg="mean",
                   letter = "F",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_breastfeed.pdf", bbox_inches = "tight")



#%% Sensory and Physical Disability - A

data2["Sensory/Physical\nDisability"] = data2["sensoryAndPhysicalDis"] == "Yes"
fig = Mat.inequality_map(data2, "Sensory/Physical\nDisability", 
                   agg="mean",
                   letter = "A",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_disability.pdf", bbox_inches = "tight")


#%% Twins - B

data2["Twins"] = data2["NumberOfBabies"] == 2
fig = Mat.inequality_map(data2, "Twins", 
                   agg="mean",
                   letter = "B",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_Twins.pdf", bbox_inches = "tight")

#%% Mental Health - C

data2["Mental Health\nIssue(s)"] = data2["MentalHealth"] == "Yes"
fig = Mat.inequality_map(data2, "Mental Health\nIssue(s)", 
                   agg="mean",
                   letter = "C",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_MentalHealth.pdf", bbox_inches = "tight")

#%% Obesity - D

data2["Obesity"] = data2["BMI>35"] == "Yes"
fig = Mat.inequality_map(data2, "Obesity", 
                   agg="mean",
                   letter = "D",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_Obesity.pdf", bbox_inches = "tight")

#%% Gestational Diabetes - E
data2["Gestational Diabetes"] = data2["Gestational_Diabetes"] == "Yes"
fig = Mat.inequality_map(data2, "Gestational Diabetes", 
                   agg="mean",
                   letter = "E",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_GestDiab.pdf", bbox_inches = "tight")

#%% Folic Acid Taken - F
data2["Folic Acid Taken"] = data2["Folic Acid Taken"] == "Yes"
fig = Mat.inequality_map(data2, "Folic Acid Taken", 
                   agg="mean",
                   letter = "F",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_FolicAcid.pdf", bbox_inches = "tight")


#%% Late booking - A

late_booking = 19

data2["Late Booking"] = data2["Late booking"] == "Yes"

fig = Mat.inequality_map(data2, "Late Booking", 
                   agg="mean",
                   letter = "A",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_latebooking.pdf", bbox_inches = "tight")

#%% Missed more than 4 apts - B

data3 = data2.copy()
data3["> 4 Missed Appointments"] = data3["> 4 missed apts"] == "Yes"

fig = Mat.inequality_map(data3, "> 4 Missed Appointments", 
                   agg="mean",
                   letter = "B",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_missedApts.pdf", bbox_inches = "tight")

#%% Consanguineous_Relationship - C
data2["Consanguineous\nUnion"] = data2["Consanguineous_Relationship"] == "Yes"

                                       
fig = Mat.inequality_map(data2, "Consanguineous\nUnion", 
                   agg="mean",
                   letter = "C",
                   eth_col = "Ethnicity Group", 
                   IMD_col = "IMD Quintile - ALL",
                   ttest = True)

fig.savefig(fig_path + "eth_IMD_consang.pdf", bbox_inches = "tight")