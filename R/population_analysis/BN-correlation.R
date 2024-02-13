library(readxl)
library(writexl)
library(dplyr)
library(corrplot)
library(tidyr)
setwd("C:/Users/TMPCDDES/OneDrive - Birmingham City Council/Documents/Main work/Maternity outcomes/code/phm-maternity/R/population_analysis")

##### Load data #####
# Load data
badger <- read_excel("../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
                     sheet = "data") %>%
  mutate(IMD = `Index of Multiple Deprivation Decile_v2`) 



badger2 <- badger %>%
  mutate(
    earlyBirth = `Deliveries under 27 weeks`,
    LBW = `BirthWeight_Grams <2500`,
    deprivedArea = case_when(
    as.numeric(IMD) < 3 ~ 1,
    TRUE ~ 0),
   Age = as.numeric(Age),
   NumberOfBabies = as.numeric(NumberOfBabies),
   FGM = case_when(
     FGM != "Yes" ~ 1,
     TRUE ~ 0),
   Consanguineous = case_when(
     Consanguineous_Relationship == "Yes" ~ 1,
     TRUE ~ 0
   ),
   BAME = case_when(
     Ethnicity != "White" ~ 1,
     TRUE ~ 0
   ),
   MentalHealth = case_when(
     MentalHealth == "Yes" ~ 1,
     TRUE ~ 0
   ),
   DomesticAbuse = case_when(
     DomesticAbuse == "Yes" ~ 1,
     TRUE ~ 0
   ),
   SmokingAtDelivery = case_when(
     SmokingAtDelivery == "Yes" ~ 1,
     TRUE ~ 0
     ),
   DrugAbuse = case_when(
     DrugAbuse == "Yes" ~ 1,
     TRUE ~ 0
   ),
   AlcoholAbuse = case_when(
     AlcoholAbuse == "Yes" ~ 1,
     TRUE ~ 0
   ),
   substanceAbuse = case_when(
     substanceAbuse == "Yes" ~ 1,
     TRUE ~ 0
   ),
   Homeless = case_when(
     Homeless == "Yes" ~ 1,
     TRUE ~ 0
   ),
   HousingIssues = case_when(
     HousingIssues == "Yes" ~ 1,
     TRUE ~ 0
   ),
   Citizenship = case_when(
     Citizenship == "Yes" ~ 1,
     TRUE ~ 0
   ),
   Obese = case_when(
     `BMI>35` == "Yes" ~ 1,
     TRUE ~ 0,
     
   )) %>%
  select(c("earlyBirth", "LBW", "Age","deprivedArea",
           "NumberOfBabies","BAME", "Consanguineous", "FGM",
           "MentalHealth", "DomesticAbuse", "DrugAbuse", 
           "AlcoholAbuse", "substanceAbuse","SmokingAtDelivery",
           "Obese", "Homeless","HousingIssues", "Citizenship"
           )) %>%
  drop_na()

corrplot(cor(badger2),
         method="color", diag = FALSE, 
         type = 'upper')


fgm_checker <- badger %>%
  mutate(
    FGM = case_when(
      FGM == "Yes" ~ 1,
      FGM == "No" ~ 0
    )
  ) %>%
  group_by(badger$EthnicCategory_Revised) %>%
  summarise(
    `FGM %` = 100*round(mean(FGM),3),
    `FGM births` = sum(FGM),
    `total births` = n()
    ) %>%
  arrange(desc(`FGM %`))
View(fgm_checker)