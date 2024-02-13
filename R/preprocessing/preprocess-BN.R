# BadgerNet Preprocessing

library(writexl)
library(dplyr)
#library(DescTools)

# Load data
badger1 <- readxl::read_excel("../../data/BadgerNet/raw/BadgerNet_Oct20_to_Oct22.xlsx",
                      sheet = "Births")
badger2 <- readxl::read_excel("../../data/BadgerNet/raw/BadgerNet_May21_to_May23.xlsx",
                      sheet = "Births") %>%
  # filter for only births that aren't in the first data set
  filter(MthYr > max(badger1$MthYr))

badger <- badger1 %>%
  select(colnames(badger2)) %>%
  rbind(badger2) %>%
  #filter(GestationAtDeliveryWeeks > 24) %>%
  mutate(
    # Term baby with weight less than 2.5kg
    LowBirthWeight = (`BirthWeight_Grams <2500`) &
           (GestationAtDeliveryWeeks > 36) &
           (!StillBirth),
    # Less than 36 weeks
    Premature = GestationAtDeliveryWeeks <= 36 &
      (!StillBirth),
    IMD_numeric = as.numeric(`Index of Multiple Deprivation Decile_v2`),
         `IMD Quintile - ALL` = floor((IMD_numeric+1)/2),
         `IMD Quintile` = case_when(
           `IMD Quintile - ALL` %in% c(1,2) ~ as.character(`IMD Quintile - ALL`),
           `IMD Quintile - ALL` %in% c(3,4,5) ~ "3+",
           TRUE ~ NA
         ),
    InterpreterRequired = case_when(
           InterpreterRequired == "y" ~ "Yes",
           InterpreterRequired == "n" ~ "No"
         ),
    `BMI>35` = case_when(
           `BMI>35` == 1 ~ "Yes",
           `BMI>35` == 0 ~ "No"
         ),
    AllEthnicities = case_when(
      # White groups
      EthnicCategory_Revised == "British" ~ "White British",
      EthnicCategory_Revised == "British_European" ~ "White British",
      EthnicCategory_Revised == "Irish_European" ~ "Irish",
      EthnicCategory_Revised == "East_European" ~ "Eastern European",
      EthnicCategory_Revised %in% c("East_European",
                                    "South_European",
                                    "North_European", 
                                    "South_African_Euro",
                                    "West_European") ~ "White-Other",
      # Asian groups
      EthnicCategory_Revised %in% c("Asian-Other", 
                                    "South_East_Asian",
                                    "Other_Far_East") ~ "Asian-Other",
      # Black groups
      EthnicCategory_Revised %in% c("North_African",
                                    "East_African",
                                    "West_African",
                                    "Central_African",
                                    "South_African_Black") ~ "Black African",
      EthnicCategory_Revised %in% c("Caribbean",
                                    "Black Caribbean",
                                    "West_African") ~ "Black Caribbean",
      # Mixed groups
      EthnicCategory_Revised == "Mixed_African-European" ~ "White and Black African",
      EthnicCategory_Revised == "Mixed_Caribbean-European" ~ "White and Black Caribbean",
      EthnicCategory_Revised %in% c("Mixed-Other",
                                    "Mixed_Asian-European") ~ "Mixed-Other",
      # Middle Eastern
      EthnicCategory_Revised == "Middle_Eastern" ~ "Middle Eastern",
      TRUE ~ EthnicCategory_Revised
    ),
    # Regression Ethnicities
    `Mother Ethnicity` = case_when(
        # Might re-group mixed depending on new reg results
           # EthnicCategory %in% c(
           #   "White and Black African", 
           #   "White and Black Caribbean", 
           #   "White and Asian",
           #   "Mixed-Other") ~ "Mixed",
           AllEthnicities %in% c(
             "NULL", 
             "Not stated", 
             "Not Known",
             "Declined to answer",
             "Unclassified") ~ "Unknown",
           TRUE ~ AllEthnicities
         ),
    `Ethnicity Group` = case_when(
      `Mother Ethnicity` %in% c(
        "White British",
        "Irish",
        "White-Other",
        "Eastern European"
      ) ~ "White",
      `Mother Ethnicity` %in% c(
          "White and Black African",
          "White and Black Caribbean",
          "White and Asian",
          "Mixed-Other") ~ "Mixed",
      `Mother Ethnicity` %in% c(
          "Asian-Other",
          "Indian",
          "Pakistani",
          "Bangladeshi",
          "Chinese"
      ) ~ "Asian",
      `Mother Ethnicity` %in% c(
        "Black African",
        "Black Caribbean",
        "Black-Other"
      ) ~ "Black",
      `Mother Ethnicity` %in% c(
        "Any Other ethnic group"
      ) ~ "Other",
      TRUE ~ `Mother Ethnicity`,
    ),
    SmokingAtDelivery = case_when(
           SmokingAtDelivery == 0 ~ "No",
           SmokingAtDelivery == 1 ~ "Yes"
         )) %>%
  # Remove things we don't need
  select(
    -c(
      "Ind_Name",
      "MotherID",
      "MotherNHS",
      "BabyID",
      "BabyNHS",
    )
  ) %>%
  mutate(
    FGM = case_when(
      FGM == 0 ~ "No",
      FGM == 1 ~ "Yes",
    ),
    ReducedFetalMovement = case_when(
      ReducedFetalMovement == 0 ~ "No",
      ReducedFetalMovement == 1 ~ "Yes",
    ),
    BreastfeedAtInitiation = case_when(
      BreastfeedAtInitiation == 0 ~ "No",
      BreastfeedAtInitiation == 1 ~ "Yes",
    ),
    BreastfeedAtDischarge = case_when(
      BreastfeedAtDischarge == 0 ~ "No",
      BreastfeedAtDischarge == 1 ~ "Yes",
    ),
    BreastfeedAndTransfertoHCWorker = case_when(
      BreastfeedAndTransfertoHCWorker == 0 ~ "No",
      BreastfeedAndTransfertoHCWorker == 1 ~ "Yes",
    ),
    FolicAcidTakenDuringPregnancy = case_when(
      FolicAcidTakenDuringPregnancy == 0 ~ "No",
      FolicAcidTakenDuringPregnancy == 1 ~ "Yes",
    ),
    MissedANAppointments = case_when(
      MissedANAppointments == 0 ~ "No",
      TRUE ~ as.character(MissedANAppointments)
    ),    
    Gestational_Diabetes = case_when(
      Gestational_Diabetes == 0 ~ "No",
      Gestational_Diabetes == 1 ~ "Yes",
    ),
    Consanguineous_Relationship = case_when(
      Consanguineous_Relationship == 0 ~ "No",
      Consanguineous_Relationship == 1 ~ "Yes",
    ),
    Genetic_Disorder = case_when(
      Genetic_Disorder == 0 ~ "No",
      Genetic_Disorder == 1 ~ "Yes",
    ),
    `Late booking` = case_when(
      GestationAtBookingWeeks <= 19 ~ "No",
      GestationAtBookingWeeks > 19 ~ "Yes",
      TRUE ~ "Unknown"
    ),
    `> 4 missed apts` = case_when(
      MissedANAppointments <= 4 ~ "No",
      MissedANAppointments == "No" ~ "No",
      MissedANAppointments > 4 ~ "Yes",
      TRUE ~ "Unknown"
    ),
      "Social Services" = SocialServicesInvolvement,
      "LD" = LearningDisabilities,
      "Folic Acid Taken" = FolicAcidTakenDuringPregnancy,
      "Consanguineous Union" = Consanguineous_Relationship,
      "Financial/Housing Issues" = as.factor(case_when(
        HousingIssues =="Yes" ~ "Yes",
        FinancialIssues =="Yes" ~ "Yes",
        TRUE ~ "NO",
      )),
      "English Difficulties" = as.factor(case_when(
        DiffUndEnglish == "Yes" ~ "Yes",
        InterpreterRequired == "Yes" ~ "Yes",
        TRUE ~ "NO"
      )),
      "Age Group" = as.factor(case_when(
        Age < 20 ~ "Less than 20",
        Age < 30 ~ "20-29",
        Age < 40 ~ "30-39",
        Age >= 40 ~ "40+",
        TRUE ~ "Unknown"
      ))

  )

badger <- badger %>%
  left_join(
    readxl::read_excel("../../data/BadgerNet/BadgerNet-ethnicities.xlsx") %>%
      select(-c("n"))
  )

badger$`IMD Quintile`[badger$`IMD Quintile` == 0] = NA

# Apply filters
len0 <- nrow(badger)
print(paste("Intitial size:", len0))

# NULL and non-registerable births
print("Applying filter: NULL and non-registerable births...")
badger <- badger %>%
  filter(!(`FinalOutcome` %in% c("NULL", "Non Registerable Birth")))
len1 <- nrow(badger)

print(paste(len0 - len1, " entries removed"))

# First delivery only
print("Applying filter: Only first births...")
badger <- badger %>%
  filter(`TotalDeliveries` == 1)
len2 <- nrow(badger)

print(paste(len1 - len2, " entries removed"))

# First delivery only
print("Applying filter: Only remove triplets and quads...")
badger <- badger %>%
  filter(`NumberOfBabies` <= 2)
len3 <- nrow(badger)

print(paste(len2 - len3, " entries removed"))

# Unknown IMD
print("Applying filter: Unknown IMD...")
badger <- badger %>%
  filter(!(is.na(`IMD Quintile`)))
len4 <- nrow(badger)

print(paste(len3 - len4, " entries removed"))

print("Applying filter: Unknown missed appointments...")
badger <- badger %>%
  filter(`> 4 missed apts` != "Unknown")
len5 <- nrow(badger)

print(paste(len4 - len5, " entries removed"))


print(paste("Final size:", len5))
# Get empty dataframe 
empty_badger <- badger %>%
  filter(`IMD Quintile` == "Impossible")



# dataset_names <- list('data' = badger, 
#                       'reference' = empty_badger)

arrow::write_parquet(
  badger,
  sink = "../../data/BadgerNet/BadgerNet-processed.parquet"
  )

# openxlsx::write.xlsx(dataset_names, 
#                      file = '../../data/BadgerNet/BadgerNet-processed.xlsx') 
