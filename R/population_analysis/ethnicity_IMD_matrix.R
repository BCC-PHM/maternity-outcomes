# Pre-processing MSDSv1 data
library(dplyr)
library(readxl)
library(ggplot2)
library(writexl)


MSDS <- read_excel("../../data/MSDS_v1.xlsx") %>%
  mutate(LSOA = LSOAMother2011) %>%
  select(c("LSOA", "EthnicCategoryMother")) %>%
  mutate(`Broad Ethnicity` = case_when(
    EthnicCategoryMother %in% c("A", "B", "C") ~ "White",
    EthnicCategoryMother %in% c("D", "E", "F", "G") ~ "Mixed",
    EthnicCategoryMother %in% c("H", "J", "K", "L") ~ "Asian",
    EthnicCategoryMother %in% c("M", "N", "P") ~ "Black",
    EthnicCategoryMother %in% c("R", "S") ~ "Other",
    TRUE ~ "Unknown"
  ))

IMD <- read_excel("../../data/brum_imd.xlsx")

MSDS_IMD <- MSDS %>%
  left_join(IMD) %>%
  filter(!is.nan(IMD)) %>%
  select(c("Broad Ethnicity", "IMD")) %>%
  mutate(IMD = ceiling(IMD/2))

eth_tots <- MSDS_IMD %>%
  group_by(`Broad Ethnicity`) %>%
  summarize(total = n())

eth_IMD <- MSDS_IMD %>%
  group_by(`Broad Ethnicity`, IMD) %>%
  summarize(n = n())

perc <- eth_tots %>%
  left_join(eth_IMD) %>%
  mutate(perc = n/total)


loadfonts(device = "win")

ggplot(data = perc, mapping = aes(x = IMD, y = `Broad Ethnicity`)) +
  geom_tile(aes(fill=perc), color = "white") +
  scale_fill_gradient(low = "white", high = "#E31D86") +
  labs(title="Mother IMD by Ethnicity",
       x ="IMD Decile", y = "") +
  theme_bw() +
  theme(legend.position = "None")

write_xlsx(perc, "../../data/IMD_eth_plot_data.xlsx")
