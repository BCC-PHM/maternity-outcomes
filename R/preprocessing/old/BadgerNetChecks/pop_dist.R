library(readxl)
library(writexl)
library(dplyr)

# BadgerNet population analysis
badger <- read_excel("../../data/BadgerNet/BadgerNet.xlsx",
                     sheet = "Births") %>%
  mutate("InterpreterRequired" = case_when(
    InterpreterRequired == "y" ~ "Yes",
    InterpreterRequired == "n" ~ "No"
  ))
  select(
    c("Site", 
     "TotalDeliveries",
     "NumberOfBabies",
     "Age",
     "Agelessthan20",
     "DrugAbuse",
     "AlcoholAbuse",
     "substanceAbuse",
     "SocialServicesInvolvement",
     "DomesticAbuse",
     "FGM",
     "LearningDisabilities",
     "DiffUndEnglish",
     "Unsupported",
     "MentalHealth",
     "MentalHealthOutcome",
     "Homeless",
     "HousingIssues",
     "FinancialIssues",
     "GypsyTravelingFamilies",
     "sensoryAndPhysicalDis",
     "Citizenship",
     "ChildProtection",
     "PrimaryLanguage",
     "InterpreterRequired",
     "EthnicCategory",
     "LocationofDelivery",
     "SmokingAtDelivery",
     "FinalOutcome"))

#### Basic count ####
count_names <- list()

for (col in colnames(badger)){
  new_count <- badger %>%
    group_by_at(col) %>%
    summarise(n = n()) %>%
    arrange(desc(n))
  count_names <- append(count_names, list(a = new_count))
}

names(count_names) <- gsub("/", "-",colnames(badger))

write_xlsx(count_names,
           "../../data/outputs/BadgerNet checks/badger_basic_counts.xlsx")

#### mental health plus ####

compare_vars = c(
  "DrugAbuse",
  "AlcoholAbuse",
  "substanceAbuse",
  "SmokingAtDelivery",
  "Agelessthan20",
  "LearningDisabilities",
  "InterpreterRequired",
  "Homeless",
  "HousingIssues",
  "FinancialIssues",
  "GypsyTravelingFamilies",
  "sensoryAndPhysicalDis"
  )

compare_names <- list()

for (var in compare_vars) {
    compare1 <- badger %>%
      select(c("MentalHealth", all_of(var))) 
    
    compare2 <- compare1 %>%
      filter(compare1[var] == "No") %>%
      group_by_at("MentalHealth") %>%
      summarize(No = n()) %>%
      left_join(
        compare1 %>%
          filter(compare1[var] == "Yes") %>%
          group_by_at("MentalHealth") %>%
          summarize(Yes = n())
      )
    compare_names <- append(compare_names, list(a = compare2))
}

names(compare_names) <- compare_vars

write_xlsx(compare_names,
           "../../data/outputs/BadgerNet checks/badger_MH_counts.xlsx")
