# -*- coding: utf-8 -*-
"""
Outcome pivot table
"""
import pandas as pd
import numpy as np
import EquiPy.Matrix as Mat

#%% Load data
data = pd.read_parquet('../data/BadgerNet/BadgerNet-processed.parquet', 
                        engine='pyarrow')

data["Intermediate Outcome"] = np.where(data["LowBirthWeight"], "LBW",
                               np.where(data["Premature"], "Premature",
                               "Healthy"))

data["Final Outcome"] = np.where(data["StillBirth"], "Stillbirth",
                               np.where(data["NeonatalDeath"], "Neonatal Death",
                               "Healthy"))

count_pivot = Mat.get_pivot(
        data, 
        eth_col = "Intermediate Outcome", 
        IMD_col = "Final Outcome",
        mode="count"
        )

print(count_pivot.to_latex())