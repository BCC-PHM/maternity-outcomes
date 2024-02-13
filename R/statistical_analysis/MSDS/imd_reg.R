### Just IMD
library(readxl)
library(openxlsx)
library(dplyr)
library(stringr)

#### Load data ####

msds <- read_excel("../../data/MSDS/MSDSv1_processed_unknowns.xlsx") %>%
  select(-c("ApgarScore5", "EthnicDescriptionMother")) %>%
  mutate("Premature or LBW" = Premature | LowBirthWeight,
         BroadEthnicityMother = case_when(
           BroadEthnicityMother == "NULL" ~ "Unknown",
           TRUE ~ BroadEthnicityMother
         ))

cols <- colnames(msds)
msds <- data.table::data.table(msds)
msds[,(cols):=lapply(.SD, as.factor),.SDcols=cols]

msds$AgeGroupAtBirthMother <- relevel(msds$AgeGroupAtBirthMother, ref = "25-30")
msds$IMD_quintile <- relevel(msds$IMD_quintile, ref = "3")
msds$BroadEthnicityMother <- relevel(msds$BroadEthnicityMother, ref = "White")
msds$FirstLanguageEnglishIndMother  <- relevel(msds$FirstLanguageEnglishIndMother, ref = "Yes")

msds$SmokingStatusDesc  <- relevel(msds$SmokingStatusDesc, ref = "Never smoked")
msds$BMI_category  <- relevel(msds$BMI_category, ref = "healthy weight")

colnames(msds) <- paste(colnames(msds), ":", sep = "")

#### train model ####

model_lbw <- glm(`LowBirthWeight:` ~ `IMD_quintile:`,
                 family = quasibinomial, 
                 data=msds)

model_prem <- glm(`Premature:` ~ `IMD_quintile:`,
                  family = quasibinomial, 
                  data=msds)

model_both <- glm(`Premature or LBW:` ~ `IMD_quintile:`,
                  family = quasibinomial, 
                  data=msds)

#### Get base rows ####

dud_varnames <- rownames(data.frame(exp(coef(model_lbw))[-1]))

variable_base <- data.frame(
  FullVar = dud_varnames,
  `Variable group` = str_split(dud_varnames, ':', simplify = TRUE)[,1],
  Variable = str_split(dud_varnames, ':', simplify = TRUE)[,2]
)
variable_base$`Variable.group` <- gsub("`", "",as.character(variable_base$`Variable.group`))
variable_base$Variable <- gsub("`","",as.character(variable_base$Variable))
#### Get odds ratios and CI ####

## Low birth weight

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

## Premature birth

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

## Low birth weight

odds_both <- round(exp(coef(model_both))[-1],3)
conf_both <- exp(confint(model_both))[-1, ]
both_odds <- variable_base %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(odds_both)),
      `Odds Ratio` = odds_both
    )
  ) %>%
  full_join(
    data.frame(
      FullVar = rownames(data.frame(conf_both)),
      `Conf int lower` = round(conf_both[,1],3),
      `Conf int upper` = round(conf_both[,2],3)
    )
  ) %>%
  select(c("Variable.group", "Variable",  "Odds.Ratio", "Conf.int.lower", "Conf.int.upper"))

colnames(both_odds) = c("Variable group", "Variable", "Odds Ratio", 
                        "Conf int lower", "Conf int upper")

# Remove rows with confidence interval too large
conf_cut_off <- 1
prem_odds <- prem_odds %>%
  filter((`Conf int upper` - `Conf int lower`) < conf_cut_off)
lbw_odds <- lbw_odds %>%
  filter((`Conf int upper` - `Conf int lower`) < conf_cut_off)
both_odds <- both_odds %>%
  filter((`Conf int upper` - `Conf int lower`) < conf_cut_off)

dataset_names <- list('Premature' = na.omit(prem_odds), 
                      'Low birth weight' = na.omit(lbw_odds), 
                      'Both' = na.omit(both_odds))

## Change group variable names
for (set in c("Premature", "Low birth weight", "Both")) {
  # Previous Caesarean Sections
  dataset_names[set][[1]]["Variable group"][dataset_names[set][[1]]["Variable group"] == "IMD_quintile"] <- "IMD"

}

openxlsx::write.xlsx(dataset_names, 
                     file = '../../data/outputs/IMD_reg_results.xlsx') 