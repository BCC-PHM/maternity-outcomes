library(writexl)
library(dplyr)
library(stringr)
library(ggplot2)

source("Main work/MiscCode/r-regression-tools/r-regression-tools.R")
setwd("Main work/Maternity outcomes/code/phm-maternity/R/statistical_analysis/BadgerNet")

##### Load data #####
# Load data
badger <- load_with_ref(
  "../../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
  data_sheet = "data",
  ref_sheet = "reference"
)
  
# Add colon to allow easier separation later
colnames(badger) <- paste(colnames(badger), ":", sep = "")

##### Perform automatic regression ##### 
variables <- c(
  "`NumberOfBabies:`", "`Ethnicity:`", "`Gestational_Diabetes:`",
  "`SmokingAtDelivery:`", "`BMI>35:`"
)

lbw_formula <- all_pairs("`LowBirthWeight:`", variables)

lbw_init <- glm(lbw_formula,
                 family = binomial, 
                 data=badger)

lbw_auto <- MASS::stepAIC(lbw_init, direction="both")

print(paste(
  "LBW:",
  formula(lbw_auto)
))

lbw_auto2 <- glm(formula(lbw_auto),
                 family = binomial, 
                 data=badger)

prem_full_formula <- all_pairs("`Premature:`", variables)

prem_init <- glm(prem_full_formula,
                family = binomial, 
                data=badger)

prem_auto <- MASS::stepAIC(prem_init, direction="both")

print(paste(
  "Prem:",
  formula(prem_auto)
))
prem_auto2 <- glm(formula(prem_auto),
                 family = binomial, 
                 data=badger)

#### Calculate variable importance ####

varImp_lbw <- var_imp(lbw_auto2)
head(varImp_lbw, 10)

varImp_prem <- var_imp(prem_auto2)
head(varImp_lbw, 10)

# save data 
varImp_datasets <- list('Premature' = na.omit(varImp_prem), 
                        'Low birth weight' = na.omit(varImp_lbw))

openxlsx::write.xlsx(varImp_datasets, 
                     file = '../../../data/outputs/badger_varImp_withMarg.xlsx') 

##### Plot ROC ####

# Low birth weight

# init_lbw_prob <- predict(lbw_init, type = "response") 
# lbw_auto_prob <- predict(lbw_auto2, type = "response") 

# badger_lwb_init <- badger %>%
#   select(
#     c("LowBirthWeight:",
#       gsub("`","",attr(terms(lbw_init), "term.labels")))
#     ) %>% 
#   na.omit()

# badger_lwb_auto <- badger %>%
#   select(
#     c("LowBirthWeight:",
#       gsub("`","",attr(terms(lbw_auto2), "term.labels")))
#   ) %>% 
#   na.omit()

# ROC <- roc(badger_lwb_init$`LowBirthWeight:` , init_lbw_prob)
# auc(ROC)
# 
# ROC_auto <- roc(badger_lwb_auto$`LowBirthWeight:` , lbw_auto_prob)
# auc(ROC_auto)
# 
# # Premature birth
# init_prem_prob <- predict(prem_init, type = "response") 
# prem_auto_prob <- predict(prem_auto2, type = "response") 
# 
# badger_prem_init <- badger %>%
#   select(
#     c("LowBirthWeight:",
#       gsub("`","",attr(terms(prem_init), "term.labels")))
#   ) %>% 
#   na.omit()
# 
# badger_prem_auto <- badger %>%
#   select(
#     c("LowBirthWeight:",
#       gsub("`","",attr(terms(prem_auto2), "term.labels")))
#   ) %>% 
#   na.omit()
# 
# ROC <- roc(badger_prem_init$`LowBirthWeight:` , init_prem_prob)
# auc(ROC)
# 
# ROC_auto <- roc(badger_prem_auto$`LowBirthWeight:` , prem_auto_prob)
# auc(ROC_auto)



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




# variable_change <-
#   data.frame(
#     `Initial Variables` = gsub(":","",as.character(attr(terms(lbw_init), "term.labels")))
#   ) %>%
#   full_join(
#     data.frame(
#       `Initial Variables` = gsub(":","",as.character(attr(terms(lbw_auto), "term.labels"))),
#       `LBW Auto` = gsub(":","",as.character(attr(terms(lbw_auto), "term.labels")))
#     )
#   ) %>%
#   left_join(
#     data.frame(
#       `Initial Variables` = gsub(":","",as.character(attr(terms(prem_auto), "term.labels"))),
#       `Premature Auto` = gsub(":","",as.character(attr(terms(prem_auto), "term.labels")))
#     )
#   )
# 
# openxlsx::write.xlsx(variable_change, 
#                       file = '../../../data/outputs/BN-auto-var-select.xlsx')