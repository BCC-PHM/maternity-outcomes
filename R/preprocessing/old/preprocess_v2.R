# Pre-processing MSDSv1 data
library(dplyr)
library(readxl)
library(ggplot2)
library(writexl)


MSDS <- read_excel("../../data/MSDS/MSDS_v1.xlsx") %>%
  mutate(LSOA = LSOAMother2011) %>%
  mutate(
    BirthWeight = as.numeric(BirthWeight),
    GestationLengthBirth = as.numeric(GestationLengthBirth),
    LowBirthWeight = case_when(
      BirthWeight < 2500 &
        GestationLengthBirth >= 37*7 ~ TRUE,
      is.numeric(BirthWeight) ~ FALSE,
      TRUE ~ NA
    ),
    Premature = case_when(
      GestationLengthBirth >= 24*7 &
        GestationLengthBirth <= 36*7 ~ TRUE,
      # any other numeric value
      is.numeric(GestationLengthBirth) ~ FALSE,
      TRUE ~ NA
    ),
    PhysicalDisabilityStatusIndMother = case_when(
      PhysicalDisabilityStatusIndMother == "Y" ~ "Yes",
      PhysicalDisabilityStatusIndMother == "N" ~ "No",
      TRUE ~ "Unknown"),
    FirstLanguageEnglishIndMother = case_when(
      FirstLanguageEnglishIndMother == "Y" ~ "Yes",
      FirstLanguageEnglishIndMother == "N" ~ "No",
      TRUE ~ "Unknown"),
    late_booking = case_when(
      late_booking == "1" ~ "Yes",
      late_booking == "0" ~ "No",
      TRUE ~ "Unknown"),
    MentalHealthIssues = case_when(
      MHPredictionDetectionIndMother == "Y" ~ "Yes",
      MHPredictionDetectionIndMother == "N" ~ "No",
      TRUE ~ "Unknown"),
    ComplexSocialFactors = case_when(
      ComplexSocialFactorsInd == "Y" ~ "Yes",
      ComplexSocialFactorsInd == "N" ~ "No",
      TRUE ~ "Unknown"),
    # Age brackets chosen to match ONS groups
    AgeGroupAtBirthMother = case_when(
      AgeAtBirthMother < 20 ~ "<20",
      AgeAtBirthMother >= 20 & AgeAtBirthMother < 25 ~ "20-24",
      AgeAtBirthMother >= 25 & AgeAtBirthMother < 30 ~ "25-30",
      AgeAtBirthMother >= 30 & AgeAtBirthMother < 35 ~ "30-34",
      AgeAtBirthMother >= 35 & AgeAtBirthMother < 40 ~ "35-39",
      AgeAtBirthMother >= 40 ~ "40+",
      TRUE ~ "Unknown"),
    ApgarScore5 = as.numeric(ApgarScore5),
    NHS_Trust = case_when(
      OrgCodeLocalPatientIdBaby == "RQ3" ~ "Women's and Children's",
      OrgCodeLocalPatientIdBaby == "RR1" ~ "Heart of England",
      OrgCodeLocalPatientIdBaby == "RRK" ~ "University Hospital",
      OrgCodeLocalPatientIdBaby == "RXK" ~ "Sandwell and West",
      TRUE ~ "Other"),
    BabySex = case_when(
      PersonPhenotypicSex == 1 ~ "Male",
      PersonPhenotypicSex == 2 ~ "Female",
      TRUE ~ "Other"),
    EmploymentDescMother = case_when(
      EmploymentStatusMother == "1" ~ "Employed",
      EmploymentStatusMother == "2" ~ "Seeking work",
      EmploymentStatusMother == "3" ~ "In education",
      EmploymentStatusMother == "4" ~ "Long-term sick",
      EmploymentStatusMother == "5" ~ "Homemaker",
      EmploymentStatusMother == "6" ~ "Not seeking work",
      EmploymentStatusMother == "7" ~ "Voluntary work",
      EmploymentStatusMother == "8" ~ "Retired",
      TRUE ~ "Unknown"),
    SmokingStatusDesc = case_when(
      SmokingStatus == "1" ~ "Current smoker",
      SmokingStatus == "2" ~ "Stopped after conception",
      SmokingStatus == "3" ~ "Stopped <= 12 months before conception",
      SmokingStatus == "4" ~ "Stopped > 12 months before conception",
      SmokingStatus == "5" ~ "Non-smoker (unknown history)",
      SmokingStatus == "6" ~ "Never smoked",
      TRUE ~ "Unknown"),
    PreviousLiveBirths = as.numeric(PreviousLiveBirths),
    PreviousCaesareanSections = as.numeric(PreviousCaesareanSections),
    PreviousStillBirths = as.numeric(PreviousStillBirths),
    PreviousLossesLessThan24Weeks = as.numeric(PreviousLossesLessThan24Weeks),
    PreviousLiveBirths = case_when(
      PreviousLiveBirths == 0 ~ "No",
      PreviousLiveBirths > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    PreviousCaesareanSections = case_when(
      PreviousCaesareanSections == 0 ~ "No",
      PreviousCaesareanSections > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    PreviousStillBirths = case_when(
      PreviousStillBirths == 0 ~ "No",
      PreviousStillBirths > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    PreviousLossesLessThan24Weeks = case_when(
      PreviousLossesLessThan24Weeks == 0 ~ "No",
      PreviousLossesLessThan24Weeks > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    AnE_visits_pre_con = case_when(
      AnE_visits_pre_con == 0 ~ "No",
      AnE_visits_pre_con > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    AnE_visits_early_preg = case_when(
      AnE_visits_early_preg == 0 ~ "No",
      AnE_visits_early_preg > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    AnE_visits_preg = case_when(
      AnE_visits_preg == 0 ~ "No",
      AnE_visits_preg > 0 ~ "Yes",
      TRUE ~ "Unknown"),
    AlcoholAtBooking = case_when(
      AlcoholUnitsPerWeek == "0" ~ "No",
      AlcoholUnitsPerWeek == "NULL" ~ "Unknown",
      TRUE ~ "Yes"),
    PersonHeight = as.numeric(PersonHeight),
    PersonWeight = as.numeric(PersonWeight),
    PersonBMI = PersonWeight/PersonHeight^2,
    BMI_category = case_when(
      PersonBMI < 18.5 ~ "underweight",
      PersonBMI >= 18.5 & PersonBMI < 25 ~ "healthy weight",
      PersonBMI >= 25 & PersonBMI < 30 ~ "overwight",
      PersonBMI >= 30 & PersonBMI < 40 ~ "obese",
      PersonBMI >= 40 ~ "severely obese",
      TRUE ~ "Unknown")
  )

IMD <- read_excel("../../data/general/brum_imd.xlsx")

MSDS <- MSDS %>%
  left_join(IMD) %>%
  mutate(IMD_quintile = as.character(ceiling(IMD/2)))

MSDS$IMD_quintile[is.na(MSDS$IMD_quintile)] = "Unknown"

MSDS_reduced <- MSDS %>%
  select(
    c(
      # Outputs
      "LowBirthWeight",
      "Premature",
      "ApgarScore5",
      # Baby
      "BabySex",
      # Mother demographics
      "AgeGroupAtBirthMother",
      "IMD_quintile",
      "EthnicDescriptionMother",
      "BroadEthnicityMother",
      "FirstLanguageEnglishIndMother",
      "EmploymentDescMother",
      # Mother mental/social factors
      "ComplexSocialFactors",
      "MentalHealthIssues",
      # Mother clinical info
      "SmokingStatusDesc",
      "AlcoholAtBooking",
      "BMI_category",
      # Clinical care
      "NHS_Trust",
      "late_booking",
      # Birth history
      "PreviousCaesareanSections",
      "PreviousLiveBirths",
      "PreviousStillBirths",
      "PreviousLossesLessThan24Weeks",
      # A&E history
      "AnE_visits_pre_con",
      "AnE_visits_early_preg",                  
      "AnE_visits_preg",
    )
  )

write_xlsx(MSDS_reduced, "../../data/MSDSv1_processed_unknowns.xlsx")
