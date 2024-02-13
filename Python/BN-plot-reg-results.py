# -*- coding: utf-8 -*-
"""
Plotting OR
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

from matplotlib import rcParams
rcParams['mathtext.fontset'] = 'stix'
rcParams['font.family'] = 'STIXGeneral'

reg_path = '../data/BadgerNet/BadgerNet-reg-results-sorted.xlsx'

bump_blue = "tab:blue"#(33/255, 194/255, 214/255)

fig = plt.figure(figsize = (10, 12))
sheets = ["LBW", "Premature", "Stillbirth", "Neonatal Death"]
for i, sheet in enumerate(sheets):
    # Load sheet
    reg_result = pd.read_excel(reg_path, sheet_name=sheet)
    
    # Split CI string
    split_strings = reg_result["95% CI"].str.split(',')
    reg_result["CI-lower"] = [float(split_i[0]) for split_i in split_strings]
    reg_result["CI-upper"] = [float(split_i[1]) for split_i in split_strings]
    
    # Calculate upper and lower error
    reg_result["error-lower"] = [max(0, reg_result["OR"][i] - reg_result["CI-lower"][i]) for i in range(len(reg_result))]
    
    reg_result["error-upper"] = [max(0, reg_result["CI-upper"][i] - reg_result["OR"][i]) for i in range(len(reg_result))] 
    
    # Move insignificant values out of plotting range
    remove_mask = reg_result["p-value"] > 0.1
    reg_result.loc[remove_mask, "OR"] = -1000
    
    # prepare new plot axis
    ax = fig.add_subplot(1,4,i+1)
    
    # Plot group regions
    borders = [0, 4, 10, 12, 14, 16, 26]
    
    for j in range(len(borders)-1):
        if j % 2 == 0:
            color = "gray"
        else:
            color = "white"
        plt.fill_between([-1, 7],
                         [borders[j]-0.5, borders[j]-0.5], 
                         [borders[j+1]-0.5, borders[j+1]-0.5],
                         color = color, alpha = 0.1,
                         lw = 0, zorder = 0)
    
    # Plot results
    n_vars = len(reg_result)
    plot_mask = (reg_result["Characteristic"] == "Unknown") + \
                (reg_result["Characteristic"] == "Twins") + \
                (reg_result["Characteristic"] == "White and Black African")
    
    reg_result["Plot_OR"] = reg_result["OR"]
    reg_result.loc[plot_mask, "Plot_OR"] = -1000
    
    ax.errorbar(reg_result["Plot_OR"],range(n_vars)[::-1], fmt = "o", ms = 6,
                color = "k",
                xerr=[reg_result["error-lower"],
                      reg_result["error-upper"]], zorder = 1,
                ecolor = "k")
    ax.plot(reg_result["Plot_OR"],range(n_vars)[::-1], "o", ms = 4,
                color = bump_blue)


    for var in [["Unknown", 16], ["Twins",9], ["White and Black African",23]]:
        if var[0] == "Twins" and sheet == "Stillbirth":
            pass
        elif var[0] == "Unknown" and sheet == "LBW":
            pass
        elif var[0] == "White and Black African" and sheet != "Stillbirth":
            pass
        else:
            mask = reg_result["Characteristic"] == var[0]
            OR = reg_result.loc[mask, "OR"].values[0]
            err_up = reg_result.loc[mask, "CI-upper"].values[0]
            err_down = reg_result.loc[mask, "CI-lower"].values[0]
            text = "OR = {:.3}\n({:.3} to {:.3})".format(OR, err_down, err_up)
            print(var, "\n\t", text)
            ax.annotate(text, (2, var[1]-0.4),ha='center', size = 9)
            ax.arrow(3., var[1], 0.3, 0, head_width = 0.23, head_length = 0.2,
                     color = "tab:red")
    # Define axis limits
    ax.set_xlim(0, 4)
    ax.plot([1,1],[-1, n_vars], "k--")
    ax.set_yticks(range(n_vars))
    ax.set_ylim(-0.5, n_vars-0.5)
    ax.set_xticks([0,1,2,3,4])
    ax.set_title(sheet, size = 16)
    
    # Assign y ticks
    if i == 0:
        ax.set_yticklabels(reg_result["Characteristic"][::-1], size = 12)
    else:
        ax.set_yticks([])
        
    ax.set_xlabel("Odds Ratio", size = 14)
        
fig.savefig("../outputs/figures/reg_results_v2.png", bbox_inches = "tight", dpi = 300)
