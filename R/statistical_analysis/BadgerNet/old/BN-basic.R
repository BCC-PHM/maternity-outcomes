# BadgerNet basic regression
#
# TODO: Group age like in other regression
setwd("C:/Users/TMPCDDES/OneDrive - Birmingham City Council/Documents/Main work/Maternity outcomes/code/phm-maternity/R/statistical_analysis/BadgerNet")

library(readxl)
library(writexl)
library(dplyr)
library(caret)
#0 ~ NA
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

model_lbw <- glm(`LowBirthWeight:` ~ `NumberOfBabies:` +  `Agelessthan20:` + `DrugAbuse:` + `AlcoholAbuse:` +
                   `substanceAbuse:` + `SocialServicesInvolvement:` + `DomesticAbuse:` +
                   `LearningDisabilities:` + `DiffUndEnglish:` + `Unsupported:` + 
                   `MentalHealth:` + `Homeless:` + `HousingIssues:` + `FinancialIssues:` +
                   `sensoryAndPhysicalDis:` + `Citizenship:` + `InterpreterRequired:` + 
                   `BMI>35:` + `IMD Quintile:` + `Ethnicity:` + `SmokingAtDelivery:` + 
                   `Gestational_Diabetes:` + `Consanguineous_Relationship:` +
                    `FolicAcidTakenDuringPregnancy:` + `FGM:`,
                 family = binomial, 
                 data=badger)

varImp_lbw <- varImp(model_lbw) %>% 
  arrange(desc(Overall)) %>% 
  mutate(index = row_number())
varImp_lbw <- cbind(variable = rownames(varImp_lbw), 
                    varImp_lbw)
rownames(varImp_lbw) <- 1:nrow(varImp_lbw)

varImpPlot_lbw <- ggplot(data= varImp_lbw, aes(x=rownames(varImp_lbw),y=Overall)) +
  geom_bar(position="dodge",stat="identity",width = 0, color = "black") + 
  coord_flip() + geom_point(color='skyblue') + xlab(" Importance Score")+
  ggtitle("Variable Importance - LBW") + 
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(panel.background = element_rect(fill = 'white', colour = 'black'))
ggsave("../../../figures/varImp_lbw.png", varImpPlot_lbw)

model_prem <- glm(`Premature:` ~ `NumberOfBabies:` +  `Agelessthan20:` + `DrugAbuse:` + `AlcoholAbuse:` +
                    `substanceAbuse:` + `SocialServicesInvolvement:` + `DomesticAbuse:` +
                    `LearningDisabilities:` + `DiffUndEnglish:` + `Unsupported:` + 
                    `MentalHealth:` + `Homeless:` + `HousingIssues:` + `FinancialIssues:` +
                    `sensoryAndPhysicalDis:` + `Citizenship:` + `InterpreterRequired:` + 
                    `BMI>35:` + `IMD Quintile:` + `Ethnicity:` + `SmokingAtDelivery:` + 
                    `Gestational_Diabetes:` + `Consanguineous_Relationship:` +
                    `FolicAcidTakenDuringPregnancy:` + `FGM:`,
                 family = binomial, 
                 data=badger)

varImp_prem <- varImp(model_prem) %>% 
  arrange(desc(Overall)) %>% 
  mutate(index = row_number())
varImp_prem <- cbind(variable = rownames(varImp_prem), 
                     varImp_prem)
rownames(varImp_prem) <- 1:nrow(varImp_prem)


varImpPlot_prem <- ggplot(data= varImp_prem, aes(x=rownames(varImp_prem),y=Overall)) +
  geom_bar(position="dodge",stat="identity",width = 0, color = "black") + 
  coord_flip() + geom_point(color='skyblue') + xlab(" Importance Score")+
  ggtitle("Variable Importance - Premature Birth") + 
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(panel.background = element_rect(fill = 'white', colour = 'black'))
ggsave("../../../figures/varImp_prem.png", varImpPlot_prem)

# Save variable importance values
varImp_datasets <- list('Premature' = na.omit(varImp_prem), 
                      'Low birth weight' = na.omit(varImp_lbw))

openxlsx::write.xlsx(varImp_datasets, 
                     file = '../../../data/outputs/badger_varImp.xlsx') 

#### Get base rows ####

dud_varnames <- rownames(data.frame(exp(coef(model_lbw))[-1]))

variable_base <- data.frame(
  FullVar = dud_varnames,
  `Variable group` = str_split(dud_varnames, ':', simplify = TRUE)[,1],
  Variable = str_split(dud_varnames, ':', simplify = TRUE)[,2]
)
variable_base$`Variable.group` <- gsub("`", "",as.character(variable_base$`Variable.group`))
variable_base$Variable <- gsub("`","",as.character(variable_base$Variable))

odds_lbw <- round(exp(coef(model_lbw))[-1],3)
conf_lbw <- exp(confint(model_lbw))[-1, ]
lbw_odds <- variable_base %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(odds_lbw)),
      `Odds Ratio` = odds_lbw
    )
  ) %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(conf_lbw)),
      `Conf int lower` = round(conf_lbw[,1],3),
      `Conf int upper` = round(conf_lbw[,2],3)
    )
  ) %>%
  select(c("Variable.group", "Variable",  "Odds.Ratio", "Conf.int.lower", "Conf.int.upper"))

colnames(lbw_odds) = c("Variable group", "Variable", "Odds Ratio", 
                       "Conf int lower", "Conf int upper")

odds_prem <- round(exp(coef(model_prem))[-1],3)
conf_prem <- exp(confint(model_prem))[-1, ]
prem_odds <- variable_base %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(odds_prem)),
      `Odds Ratio` = odds_prem
    )
  ) %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(conf_prem)),
      `Conf int lower` = round(conf_prem[,1],3),
      `Conf int upper` = round(conf_prem[,2],3)
    )
  ) %>%
  select(c("Variable.group", "Variable",  "Odds.Ratio", "Conf.int.lower", "Conf.int.upper"))

colnames(prem_odds) = c("Variable group", "Variable", "Odds Ratio", 
                        "Conf int lower", "Conf int upper")

dataset_names <- list('Premature' = na.omit(prem_odds), 
                      'Low birth weight' = na.omit(lbw_odds))

openxlsx::write.xlsx(dataset_names, 
                     file = '../../../data/outputs/prelim_badger_v1.xlsx') 