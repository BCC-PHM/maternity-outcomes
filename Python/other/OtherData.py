# -*- coding: utf-8 -*-
"""
Plotting other data e.g. from FingerTips
"""

import numpy as np
import matplotlib.pyplot as plt
#import seaborn as sns
import pandas as pd

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

#custom_params = {"axes.spines.right": False, "axes.spines.top": False}
#sns.set_theme(style="ticks", rc=custom_params)

plt.rcParams.update({'font.size': 12})

fig_path = "../../outputs/figures/"


data = pd.read_csv("..\..\data\general\inf_mort_trends_v2.csv")

#%% Infant mortality - option 1

data = data.dropna(subset=['Parent Name'])
plt.figure(figsize=(6,3))

for AreaName in ["England", "Birmingham", "Solihull"]:
    mask1 = data["AreaName"] == AreaName
    mask2 = data["Category Type"].isna()
    
    mask = mask1 * mask2
    
    y = data[mask]["Value"]#[::2]
    print(AreaName, y.values[-1])
    date = data[mask]["Time period"]#[::2]
    x = [int(date_i[:4]) + 1 for date_i in date]
    #up = data[mask]["Upper CI 95.0 limit"]#[::2]
    #down = data[mask]["Lower CI 95.0 limit"]#[::2]
    plt.plot(x, y, "-o", lw=2, label = AreaName)
    #plt.fill_between(x, down, up, alpha = 0.3)
plt.xticks(np.arange(2000, 2025,5))
plt.xlim(2002, 2021)
plt.legend()
plt.ylabel("Infant deaths under 1 year\nof age per 1000 live births", size = 14)
plt.ylim(0, 14)
plt.tight_layout()
plt.show()
plt.savefig(fig_path + "inf_mort_sep.pdf")

#%%

data = data.dropna(subset=['Parent Name'])
plt.figure(figsize=(6,3))

mask1 = data["AreaName"] == "England"
mask2 = data["Category Type"].isna()

mask = mask1 * mask2
    
y1 = data[mask]["Value"]#[::2]
date = data[mask]["Time period"]#[::2]
x = [int(date_i[:4]) + 1 for date_i in date]
plt.plot(x, y1, "-o", lw=2, label = "England")

mask_Brum = (data["AreaName"] == "Birmingham") * mask2
mask_Soli = (data["AreaName"] == "Solihull") * mask2
y2_num = data["Count"][mask_Brum].values + data["Count"][mask_Soli].values
y2_den = data["Denominator"][mask_Brum].values + data["Denominator"][mask_Soli].values

prop = y2_num/y2_den

y2 = 1000*prop

z = 1.96 # 95% CI
Bsol_err = 1000*z*np.sqrt(prop * (1-prop) / y2_den)

Bsol_up = y2 + Bsol_err
Bsol_down = y2 - Bsol_err

plt.plot(x, y2, "-o", lw=2, label = "Birmingham &\nSolihull")

plt.fill_between(x, Bsol_down, Bsol_up, alpha = 0.3, 
                 color = "tab:orange", lw=0)

plt.xticks(np.arange(2000, 2025,5))
plt.xlim(2002, 2021)
plt.legend()
plt.ylabel("Infant deaths under 1 year\nof age per 1000 live births", size = 14)
plt.ylim(0, 14)
plt.tight_layout()
plt.show()
plt.savefig(fig_path + "BSol_inf_mort.pdf", bbox_inches = "tight")