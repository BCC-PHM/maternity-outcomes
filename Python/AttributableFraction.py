"""
Calculation of the fraction of premature birth and low birth weight
attributable to ethnicity and socioeconomic deprivation (IMD)
"""

import pandas as pd

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

from EquiPy import AF

data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

#data.loc[data.loc[:,"Ethnicity"] == "Middle_Eastern","Ethnicity"] = "Middle Eastern"
#data.loc[data.loc[:,"EthnicCategory"] == "Any Other ethnic group","EthnicCategory"] = "Other"

data = data[data["NumberOfBabies"] == 1]
#%% Pre-process

data_smaller = data[["Ethnicity Group", "IMD Quintile", "Premature", "LowBirthWeight"]].copy()
data_smaller = data_smaller[data_smaller["Ethnicity Group"] != "Other"]

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
    fig_i.savefig("../outputs/figures/attrib_frac/{}_attrib_frac.pdf".format(obs),
                bbox_inches = "tight", dpi = 300)   
