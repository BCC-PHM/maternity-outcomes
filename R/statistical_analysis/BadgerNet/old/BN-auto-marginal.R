library(readxl)
library(writexl)
library(dplyr)
library(stringr)
library(MASS)
library(ggplot2)
library(pROC)
setwd("Main work/Maternity outcomes/code/phm-maternity/R/statistical_analysis/BadgerNet")

##### Load data #####
# Load data
badger <- read_excel("../../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
                     sheet = "data")

# Define reference group
ref_group <- read_excel("../../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
                     sheet = "reference")

for (col in colnames(ref_group)){
  ref = ref_group[col][[1]]
  ##cat(col, ":", ref,"\n")
  badger[[col]] <- relevel(factor(badger[[col]]), ref = ref)
}
  
# Add colon to allow easier separation later
colnames(badger) <- paste(colnames(badger), ":", sep = "")

##### Perform automatic regression ##### 

lbw_init <- glm(`LowBirthWeight:` ~ `NumberOfBabies:` *  `Agelessthan20:` * `DrugAbuse:` * `AlcoholAbuse:` *
                  `substanceAbuse:` * `SocialServicesInvolvement:` * `DomesticAbuse:` *
                  `LearningDisabilities:` * `DiffUndEnglish:` * `Unsupported:` * 
                  `MentalHealth:` * `Homeless:` * `HousingIssues:` * `FinancialIssues:` *
                  `sensoryAndPhysicalDis:` * `Citizenship:` * `InterpreterRequired:` * 
                  `BMI>35:` * `IMD Quintile:` * `Ethnicity:` * `SmokingAtDelivery:`,
                 family = binomial, 
                 data=badger)

lbw_auto <- stepAIC(lbw_init, direction="both")
lbw_auto2 <- glm(formula(lbw_auto),
                 family = binomial, 
                 data=badger)


prem_init <- glm(`Premature:` ~ `NumberOfBabies:` *  `Agelessthan20:` * `DrugAbuse:` * `AlcoholAbuse:` *
                  `substanceAbuse:` * `SocialServicesInvolvement:` * `DomesticAbuse:` *
                  `LearningDisabilities:` * `DiffUndEnglish:` * `Unsupported:` * 
                  `MentalHealth:` * `Homeless:` * `HousingIssues:` * `FinancialIssues:` *
                  `sensoryAndPhysicalDis:` * `Citizenship:` * `InterpreterRequired:` * 
                  `BMI>35:` * `IMD Quintile:` * `Ethnicity:` * `SmokingAtDelivery:`,
                family = binomial, 
                data=badger)

prem_auto <- stepAIC(prem_init, direction="both")
prem_auto2 <- glm(formula(prem_auto),
                 family = binomial, 
                 data=badger)

##### Plot ROC ####

# Low birth weight
init_lbw_prob <- predict(lbw_init, type = "response") 
lbw_auto_prob <- predict(lbw_auto2, type = "response") 

badger_lwb_init <- badger %>%
  select(
    c("LowBirthWeight:",
      gsub("`","",attr(terms(lbw_init), "term.labels")))
    ) %>% 
  na.omit()

badger_lwb_auto <- badger %>%
  select(
    c("LowBirthWeight:",
      gsub("`","",attr(terms(lbw_auto2), "term.labels")))
  ) %>% 
  na.omit()

ROC <- roc(badger_lwb_init$`LowBirthWeight:` , init_lbw_prob)
auc(ROC)

ROC_auto <- roc(badger_lwb_auto$`LowBirthWeight:` , lbw_auto_prob)
auc(ROC_auto)

# Premature birth
init_prem_prob <- predict(prem_init, type = "response") 
prem_auto_prob <- predict(prem_auto2, type = "response") 

badger_prem_init <- badger %>%
  select(
    c("LowBirthWeight:",
      gsub("`","",attr(terms(prem_init), "term.labels")))
  ) %>% 
  na.omit()

badger_prem_auto <- badger %>%
  select(
    c("LowBirthWeight:",
      gsub("`","",attr(terms(prem_auto2), "term.labels")))
  ) %>% 
  na.omit()

ROC <- roc(badger_prem_init$`LowBirthWeight:` , init_prem_prob)
auc(ROC)

ROC_auto <- roc(badger_prem_auto$`LowBirthWeight:` , prem_auto_prob)
auc(ROC_auto)



# 
# dud_varnames <- rownames(data.frame(exp(coef(model_lbw))[-1]))
# 
# variable_base <- data.frame(
#   FullVar = dud_varnames,
#   `Variable group` = str_split(dud_varnames, ':', simplify = TRUE)[,1],
#   Variable = str_split(dud_varnames, ':', simplify = TRUE)[,2]
# )
# variable_base$`Variable.group` <- gsub("`", "",as.character(variable_base$`Variable.group`))
# variable_base$Variable <- gsub("`","",as.character(variable_base$Variable))
# 
# odds_lbw <- round(exp(coef(model_lbw))[-1],3)
# conf_lbw <- exp(confint(model_lbw))[-1, ]
# lbw_odds <- variable_base %>%
#   full_join(
#     data.frame(
#       FullVar = rownames(data.frame(odds_lbw)),
#       `Odds Ratio` = odds_lbw
#     )
#   ) %>%
#   full_join(
#     data.frame(
#       FullVar = rownames(data.frame(conf_lbw)),
#       `Conf int lower` = round(conf_lbw[,1],3),
#       `Conf int upper` = round(conf_lbw[,2],3)
#     )
#   ) %>%
#   select(c("Variable.group", "Variable",  "Odds.Ratio", "Conf.int.lower", "Conf.int.upper"))
# 
# colnames(lbw_odds) = c("Variable group", "Variable", "Odds Ratio", 
#                        "Conf int lower", "Conf int upper")
# 
# openxlsx::write.xlsx(lbw_odds, 
#                      file = '../../../data/outputs/prelim_badger_v2-auto.xlsx')
# 



variable_change <-
  data.frame(
    `Initial Variables` = gsub(":","",as.character(attr(terms(lbw_init), "term.labels")))
  ) %>%
  left_join(
    data.frame(
      `Initial Variables` = gsub(":","",as.character(attr(terms(lbw_auto), "term.labels"))),
      `LBW Auto` = gsub(":","",as.character(attr(terms(lbw_auto), "term.labels")))
    )
  ) %>%
  left_join(
    data.frame(
      `Initial Variables` = gsub(":","",as.character(attr(terms(prem_auto), "term.labels"))),
      `Premature Auto` = gsub(":","",as.character(attr(terms(prem_auto), "term.labels")))
    )
  )

openxlsx::write.xlsx(variable_change, 
                      file = '../../../data/outputs/BN-auto-var-select.xlsx')