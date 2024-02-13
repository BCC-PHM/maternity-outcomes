library(readxl)
library(dplyr)
library(tidyr)
library(summarytools)

setwd("C:/Users/TMPCDDES/OneDrive - Birmingham City Council/Documents/Main work/Maternity outcomes/code/phm-maternity/R/population_analysis")

##### Load data #####
# Load data
badger <- read_excel("../../data/BadgerNet/BadgerNet-processed-withRef.xlsx",
                     sheet = "data") %>%
  select(c("NumberOfBabies",
           "DrugAbuse",
           "AlcoholAbuse",
           "substanceAbuse",
           "SocialServicesInvolvement",
           "DomesticAbuse",
           "LearningDisabilities",
           "DiffUndEnglish",
           "Unsupported",
           "MentalHealth",
           "Homeless",
           "HousingIssues",
           "FinancialIssues",
           "GypsyTravelingFamilies",
           "sensoryAndPhysicalDis",
           "Citizenship",
           "ChildProtection",
           "InterpreterRequired"))

summary <- dfSummary(badger, 
          plain.ascii  = FALSE, 
          graph.magnif = 0.75, 
          valid.col    = FALSE,
          missing.col = FALSE,
          tmp.img.dir  = "/tmp",
          varnumbers   = FALSE,
          na.col       = FALSE,
          style        = "grid")

view(summary, file = "summary.html",
     headings = FALSE,
     footnote = NA)