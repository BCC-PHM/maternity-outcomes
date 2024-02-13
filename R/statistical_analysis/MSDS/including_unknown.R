# Investigating the impact of keeping NAs as "Unknown" vs removing all lines
# with NAs

library(readxl)
library(openxlsx)
library(stats4)
library(dplyr)
library(caret)
library(InformationValue)

#### Load data ####

msds1 <- read_excel("../../data/MSDS/MSDSv1_processed.xlsx") %>%
  select(-c("Premature", "ApgarScore5", "EthnicDescriptionMother"))


# Convert all to factors 
cols <- colnames(msds1)
msds1 <- data.table::data.table(msds1)
msds1[,(cols):=lapply(.SD, as.factor),.SDcols=cols]
#msds1$LowBirthWeight = as.logical(msds1$LowBirthWeight)

msds2 <- read_excel("../../data/MSDS/MSDSv1_processed_unknowns.xlsx") %>%
  select(-c("Premature", "ApgarScore5", "EthnicDescriptionMother"))
cols2 <- colnames(msds2)
msds2 <- data.table::data.table(msds2)
msds2[,(cols2):=lapply(.SD, as.factor),.SDcols=cols2]
#msds2$LowBirthWeight = as.logical(msds2$LowBirthWeight)

msds1$AgeGroupAtBirthMother <- relevel(msds1$AgeGroupAtBirthMother, ref = "25-30")
msds1$IMD_quintile <- relevel(msds1$IMD_quintile, ref = "3")
msds1$BroadEthnicityMother <- relevel(msds1$BroadEthnicityMother, ref = "White")
msds1$FirstLanguageEnglishIndMother  <- relevel(msds1$FirstLanguageEnglishIndMother, ref = TRUE)

msds1$SmokingStatusDesc  <- relevel(msds1$SmokingStatusDesc, ref = "Never smoked")
msds1$BMI_category  <- relevel(msds1$BMI_category, ref = "healthy weight")
msds1$NHS_Trust  <- relevel(msds1$NHS_Trust, ref = "University Hospital")
#msds1$AlcoholAtBooking  <- relevel(msds1$AlcoholAtBooking, ref = "FALSE")
#msds1$MentalHealthIssues  <- relevel(msds1$MentalHealthIssues, ref = "FALSE")
#msds1$late_booking  <- relevel(msds1$late_booking, ref = "FALSE")

msds2$AgeGroupAtBirthMother <- relevel(msds2$AgeGroupAtBirthMother, ref = "25-30")
msds2$IMD_quintile <- relevel(msds2$IMD_quintile, ref = "3")
msds2$BroadEthnicityMother <- relevel(msds2$BroadEthnicityMother, ref = "White")
msds2$FirstLanguageEnglishIndMother  <- relevel(msds2$FirstLanguageEnglishIndMother, ref = TRUE)

msds2$SmokingStatusDesc  <- relevel(msds2$SmokingStatusDesc, ref = "Never smoked")
msds2$BMI_category  <- relevel(msds2$BMI_category, ref = "healthy weight")
msds2$NHS_Trust  <- relevel(msds2$NHS_Trust, ref = "University Hospital")
#msds1$AlcoholAtBooking  <- relevel(msds1$AlcoholAtBooking, ref = "FALSE")
#msds1$MentalHealthIssues  <- relevel(msds1$MentalHealthIssues, ref = "FALSE")
#msds1$late_booking  <- relevel(msds1$late_booking, ref = "FALSE")

#### Separate into training and test data ####

#make this example reproducible
set.seed(1)

#Use 70% of data set as training set and remaining 30% as testing set
sample <- sample(c(TRUE, FALSE), nrow(msds1), replace=TRUE, prob=c(0.7,0.3))

train1 <- msds1[sample, ]
test1 <- msds1[!sample, ]  

train2 <- msds2[sample, ]
test2 <- msds2[!sample, ]  

#### train model ####

model1 <- glm(LowBirthWeight ~ .,
              family = quasibinomial(link = "logit"), 
             data=train1)

model2 <- glm(LowBirthWeight ~ .,
              family = quasibinomial(link = "logit"), 
              data=train2)

pscl::pR2(model1)["McFadden"]
pscl::pR2(model2)["McFadden"]

#### Apply model to test data ####
predicted1 <- predict(model1, test1, type="response")
predicted2 <- predict(model2, test2, type="response")

#### Model diagnostics #### 

labels <- c("NAs removed","NAs as factor")

PredictABEL::plotROC(
  test1[!is.na(predicted1),],
  1,
  predrisk = cbind(predicted1[!is.na(predicted1)],
                   predicted2[!is.na(predicted1)]),
  labels = labels)