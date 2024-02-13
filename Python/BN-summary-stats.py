# -*- coding: utf-8 -*-
"""
BadgerNet summary statistics
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#%% Load data
data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')


data['Index of Multiple Deprivation Decile_v2'] = data['Index of Multiple Deprivation Decile_v2'].astype(int)
data["IMD Quintile"] = np.floor((data['Index of Multiple Deprivation Decile_v2'] + 1)/2)


#%% Generate summary statistics

# Ethnicity

eth_percs = data.value_counts("EthnicCategory_Revised")[:5]/len(data)*100
print(eth_percs)

eth_percs = data.value_counts("Ethnicity Group")[:5]/len(data)*100
print(eth_percs)
print("-"*10)

# IMD - all
IMD1 = sum(data["IMD Quintile"] == 1)
perc = 100*IMD1/len(data)
print("All: {:.3}% in the most deprived quintile".format(perc))

# Ethnicity and IMD
for eth in np.unique(data["Ethnicity Group"]):
    eth_mask = data["Ethnicity Group"] == eth
    N_eth = sum(eth_mask)
    IMD1 = sum(data[eth_mask]["IMD Quintile"] == 1)
    perc = 100*IMD1/N_eth
    print("{}: {:.3}% in the most deprived quintile".format(eth, perc))

avg_age = data["Age"].mean() # 30.4
under_20 = 100*sum(data["Agelessthan20"] == "Yes")/len(data)
under_18 = 100*np.mean(data["Age"] < 18)
under_18_n = sum(data["Age"] < 18)
print("-"*10)
print('''The average age of the mothers is {:.3}
{:.3}% of mothers are aged less than 20
{:.3}% ({}) of mothers are aged less than 18 
minimum age: {} years old'''.format(avg_age, under_20,
 under_18, under_18_n, min(data["Age"])))
print("-"*10)
most_dep = sum(np.logical_or(
    data['Index of Multiple Deprivation Decile_v2'] == 1,
    data['Index of Multiple Deprivation Decile_v2'] == 2,
    ))

# Smoking
smoking_perc = 100*np.mean(data["SmokingAtDelivery"] == 1)
print("{:.3}% of mother smoking at delivery".format(smoking_perc))

#%%
data["Smoking At Delivery"] = data["SmokingAtDelivery"] == "Yes"

plt.figure()

bar1 = sns.barplot(data, x = "Ethnicity Group", y = "Smoking At Delivery")
vals = np.array([round(h.get_height()*100,2) for h in bar1.patches])
CI = np.array([100*bar1.get_lines()[i].get_data()[1] for i in range(len(bar1.get_lines()))])
errs1 = vals - CI[:,0]
errs2 = CI[:,1] - vals
errs = np.round((errs1 + errs2)/2,2)

pd.DataFrame({"Value":vals, "+/-":errs})


plt.figure()
bar1 = sns.barplot(data, x = "IMD Quintile", y = "Smoking At Delivery")
vals = np.array([round(h.get_height()*100,2) for h in bar1.patches])
CI = np.array([100*bar1.get_lines()[i].get_data()[1] for i in range(len(bar1.get_lines()))])
errs1 = vals - CI[:,0]
errs2 = CI[:,1] - vals
errs = np.round((errs1 + errs2)/2,2)

pd.DataFrame({"Value":vals, "+/-":errs})

#%%
data["Teenage"] = (data["Age"] >=12) * (data["Age"] <= 17)
plt.figure()
bar1 = sns.barplot(data, x = "IMD Quintile", y = "Teenage")
vals = np.array([round(h.get_height()*100,2) for h in bar1.patches])
CI = np.array([100*bar1.get_lines()[i].get_data()[1] for i in range(len(bar1.get_lines()))])
errs1 = vals - CI[:,0]
errs2 = CI[:,1] - vals
errs = np.round((errs1 + errs2)/2,2)

pd.DataFrame({"Value":vals, "+/-":errs})

#%% Breastfeeding

data["Breast Fed"] = data["BreastfeedAtInitiation"] == "Yes"
plt.figure()
bar1 = sns.barplot(data, x = "Ethnicity Group", y = "Breast Fed")
vals = np.array([round(h.get_height()*100,2) for h in bar1.patches])
CI = np.array([100*bar1.get_lines()[i].get_data()[1] for i in range(len(bar1.get_lines()))])
errs1 = vals - CI[:,0]
errs2 = CI[:,1] - vals
errs = np.round((errs1 + errs2)/2,2)

pd.DataFrame({"Value":vals, "+/-":errs})