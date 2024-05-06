"""

"""

import pandas as pd
#import numpy as np

from EquiPy import AF

data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

#data.loc[data.loc[:,"Ethnicity"] == "Middle_Eastern","Ethnicity"] = "Middle Eastern"
#data.loc[data.loc[:,"EthnicCategory"] == "Any Other ethnic group","EthnicCategory"] = "Other"

data = data[data["NumberOfBabies"] == 1]


#%% Pre-process

data_smaller = data[["Ethnicity Group", "IMD Quintile", "Premature", "LowBirthWeight"]].copy()

data_smaller = data_smaller[data_smaller["Ethnicity Group"] != "Other"]
data_smaller = data_smaller[data_smaller["Ethnicity Group"] != "Middle Eastern"]

#%% Main code
titles = ["Premature Birth", "Low Birth Weight"]

for i, obs in enumerate(["Premature", "LowBirthWeight"]):
    out_count = AF.outcome_count(data_smaller, obs)
    afracs = AF.calc_AF(data_smaller, obs, n = 10)
    afrac_errs = AF.calc_errors(afracs)
    fig_i = AF.plot_AF(afrac_errs, out_count, error_range = 100,
                       insuff_text_size = 14, tick_size = 16)
    fig_i.axes[0].set_title(titles[i], size = 18)
    fig_i.axes[0].set_ylabel("IMD Quintile", size = 16)
    fig_i.savefig("../outputs/figures/attrib_frac/{}_attrib_frac-MiNet.png".format(obs),
                bbox_inches = "tight", dpi = 300)   

#%% Combined

# data_smaller["Negative Outcome"] = np.logical_or(data_smaller["Premature"],
#                                                  data_smaller["LowBirthWeight"])
# obs = "Negative Outcome"

# out_count = AF.outcome_count(data_smaller, obs)
# afracs = AF.calc_AF(data_smaller, obs, n = 10)
# afrac_errs = AF.calc_errors(afracs)

#%%
# import AttributableFraction as AF
# fig_i = AF.plot_AF(afrac_errs, out_count, error_range = 150, insuff_text_size = 8)
# #fig_i.axes[0].set_title(titles[i])
# fig_i.axes[0].set_ylabel("IMD Quintile", size = 14)
# fig_i.savefig("../outputs/figures/attrib_frac/{}_attrib_frac.pdf".format(obs),
#             bbox_inches = "tight")   
