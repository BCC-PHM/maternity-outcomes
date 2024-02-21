'''
Visualise BadgerNet regression results
'''

import sys
sys.path.append(r'C:\Users\TMPCDDES\OneDrive - Birmingham City Council\Documents\Main work\MiscCode\reg-vis')
import reg_vis
import matplotlib.pyplot as plt

# Initiate plotting class
reg_vis = reg_vis.reg_plot()
reg_vis.result_name = "Odds Ratio"
reg_vis.xlim = [0,6]

# Choose font sizes
reg_vis.font_size = 8
reg_vis.group_size = 9
reg_vis.header_size = 9
reg_vis.group_offset = -0.05
reg_vis.var_offset = -0.2

plt.close("all")

for sheet in ["LBW", "Prem"]:
    reg_vis.load_data("../data/outputs/BN_regs_DD.xlsx", sheet = sheet)
    
    mask1 = reg_vis.df["Variable group"] == "Consanguineous_Relationship"
    reg_vis.df["Variable group"][mask1] = "\nConsanguineous\nRelationship"
    
    
    mask2 = reg_vis.df["Variable group"] == "FolicAcidTakenDuringPregnancy"
    reg_vis.df["Variable group"][mask2] = "\nFolic Acid Taken\nDuring Preg"
    
    mask3 = reg_vis.df["Variable group"] == "NumberOfBabies:SocialServicesInvolvement"
    reg_vis.df["Variable group"][mask3] = "# Babies : Soc Serv"
    
    mask4 = reg_vis.df["Variable group"] == "NumberOfBabies"
    reg_vis.df["Variable group"][mask4] = "# Babies"
    
    mask5 = reg_vis.df["Variable group"] == "SocialServicesInvolvement"
    reg_vis.df["Variable group"][mask5] = "Soc Serv Inv"
    
    mask6 = reg_vis.df["Variable group"] == "NumberOfBabies:Ethnicity"
    reg_vis.df["Variable group"][mask6] = "# Babies:Ethnicity"

    reg_vis.plot(group1_color = None,
                 group2_color = "tab:red",
                 group_alpha = 0.15,
                 head_fill = "gray",
                 length_scale = 1.1)
    
    # Save visualisation
    reg_vis.save_plot("../figures/BN_reg_DD_{}.pdf".format(sheet))