# BadgerNet Attributable fraction
#
# Attributable fraction = (Rate(exposed) - Rate(unexposed))/Rate(exposed)
#
# Here, "unexposed" means "White women in least deprived quintile".

library(writexl)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(gtsummary)

source("~/Main work/MiscCode/r-regression-tools/r-regression-tools.R")
setwd("~/Main work/Maternity outcomes/phm-maternity/R/statistical_analysis/BadgerNet")

# Load data
badger_load <- load_with_ref(
  "../../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
  data_sheet = "data",
  ref_sheet = "reference",
  add_colon = FALSE,
  return_ref = TRUE
)

badger <- badger_load[[1]] %>%
  # filter for singlton babies
  filter(NumberOfBabies == 1) %>%
  select(c("IMD Quintile", "Ethnicity", "LowBirthWeight", "Premature"))


prem_fracs <- badger %>%
  # Aggregate IMD 3, 4 and 5 to "3+"
  mutate(
    `IMD Quintile` = case_when(
      `IMD Quintile` %in% c(3,4,5) ~ "3+",
      TRUE ~ `IMD Quintile`
    )) %>%
  # Take out unkown IMD values
  filter(!is.na(`IMD Quintile`)) %>%
  # Group by IMD and ethnicity
  group_by(`IMD Quintile`, `Ethnicity`) %>%
  summarise(
    n = n(), # total number
    P = sum(Premature)/n() # group risk
    )

# Get rate for reference group
condition1 <- prem_fracs$`IMD Quintile` == "3+"
condition2 <- prem_fracs$`Ethnicity` == "White"
P_ref <- prem_fracs$P[condition1 & condition2]

# calculate attributable fraction
prem_fracs$attrib_frac <- round((prem_fracs$P - P_ref)/prem_fracs$P,3)
# calculate attributable percentage
prem_fracs$attrib_perc <- 100*prem_fracs$attrib_frac


prem_fracs %>%
  select(c("Ethnicity",
           "IMD Quintile",
           "attrib_perc")) %>%
  tidyr::spread(prem_fracs, key = "Ethnicity", value = "attrib_perc")

