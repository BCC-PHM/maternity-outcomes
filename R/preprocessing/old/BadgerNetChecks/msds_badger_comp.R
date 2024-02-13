# Script to determine and compare the scope and completeness of the 
# MSDSv1 and BadgerNet data sets.

library(readxl)
library(writexl)
library(readr)
library(dplyr)
library(ggplot2)

msds <- read_excel("../../data/MSDS/MSDSv1_processed.xlsx")
badger <- read_excel("../../data/BadgerNet/BadgerNet.xlsx",
                     sheet = "Births")

# get msds dates
msds_raw <- read_excel("../../data/MSDS/MSDS_v1.xlsx") 
msds_first_date <- min(msds_raw$birth_date)
msds_last_date <- max(msds_raw$birth_date)
#msds_raw <- 0

msds_rows <- nrow(msds)
badger_rows <- nrow(badger)

badger_first_date <- min(badger$MthYr)
badger_last_date <- max(badger$MthYr)

msds_text <- paste("MSDS:\n", 
                   "  -", msds_rows, "rows\n", 
                   "  -", "dates from", msds_first_date, "to", msds_last_date, "\n",
                   "  -", "total of", msds_last_date - msds_first_date, "days")

badger_text <- paste("BadgerNet:\n", 
                   "  -", badger_rows, "rows\n", 
                   "  -", "dates from", badger_first_date, "to", badger_last_date, "\n",
                   "  -", "total of", badger_last_date - badger_first_date, "days")

#### births per month ####
msds_count <- msds_raw %>% 
  count(month = as.Date(paste(format(birth_date, '%Y-%m'), "-15", sep = "")))
#glimpse(msds_count)

badger_count <- badger %>% 
  count(month = as.Date(paste(format(MthYr, '%Y-%m'), "-15", sep = ""))) %>%
  filter(!(month == "2022-10-15"))
#glimpse(badger_count)

numbers <- ggplot(msds_count, 
                  aes(x = month, y = n, color = "MSDSv1")) +
  geom_line(size=1) +
  geom_line(data = badger_count, 
            aes(x = month, y = n, color = "BadgerNet"),
            size=1)+
  theme_bw() +
  ylab("Monthly number of births") +
  xlab("") +
  ylim(0, 1700) +
  theme(legend.position = c(.825, .2),
        legend.title = element_blank(),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"),
        legend.margin=margin(c(0,5,5,5)))
numbers
ggsave("number_comp.png", numbers, 
       path = "figures/badger_comp",
       width = 4, height = 2.5, dpi = 300,
       units = "in", device='png')

writeLines(msds_text)
writeLines(badger_text)      

msds_raw <- 0

#### Data completeness ####

msds_complete_t <- msds %>%
  summarize(LowBirthWeight = 100*round(mean(!is.na(LowBirthWeight)),3),
            Premature = 100*round(mean(!is.na(Premature)),3),
            ApgarScore5 = 100*round(mean(!is.na(ApgarScore5)),3),
            BabySex = 100*round(mean(!is.na(BabySex)),3),
            AgeGroupAtBirthMother = 100*round(mean(!is.na(AgeGroupAtBirthMother)),3),
            IMD_quintile = 100*round(mean(!is.na(IMD_quintile)),3),
            EthnicDescriptionMother = 100*round(mean(!is.na(EthnicDescriptionMother)),3),
            BroadEthnicityMother = 100*round(mean(!is.na(BroadEthnicityMother)),3),
            FirstLanguageEnglishIndMother = 100*round(mean(!is.na(FirstLanguageEnglishIndMother)),3),
            EmploymentDescMother = 100*round(mean(!is.na(EmploymentDescMother)),3),
            ComplexSocialFactors = 100*round(mean(!is.na(ComplexSocialFactors)),3),
            MentalHealthIssues = 100*round(mean(!is.na(MentalHealthIssues)),3),
            SmokingStatusDesc = 100*round(mean(!is.na(SmokingStatusDesc)),3),
            AlcoholAtBooking = 100*round(mean(!is.na(AlcoholAtBooking)),3),
            BMI_category = 100*round(mean(!is.na(BMI_category)),3),
            NHS_Trust = 100*round(mean(!is.na(NHS_Trust)),3),
            late_booking = 100*round(mean(!is.na(late_booking)),3),
            PreviousCaesareanSections = 100*round(mean(!is.na(PreviousCaesareanSections)),3),
            PreviousLiveBirths = 100*round(mean(!is.na(PreviousLiveBirths)),3),
            PreviousStillBirths = 100*round(mean(!is.na(PreviousStillBirths)),3),
            PreviousLossesLessThan24Weeks = 100*round(mean(!is.na(PreviousLossesLessThan24Weeks)),3),
            AnE_visits_pre_con = 100*round(mean(!is.na(AnE_visits_pre_con)),3),
            AnE_visits_early_preg  = 100*round(mean(!is.na(AnE_visits_early_preg)),3),
            AnE_visits_preg = 100*round(mean(!is.na(AnE_visits_preg)),3),
            )
msds_complete_unnamed <- data.frame(t(msds_complete_t))
msds_complete_unnamed$variable = rownames(msds_complete_unnamed)

msds_complete <- rename(msds_complete_unnamed,
                        `MSDS completeness` = t.msds_complete_t.)

badger_complete_t <- badger %>%
  summarize(
    LowBirthWeight = 100*round(mean(!(`BirthWeight_Grams <2500`=="NULL")),3),
    Premature = 100*round(mean(!(GestationAtDeliveryWeeks == "NULL")),3),
    ApgarScore5 = NA,
    BabySex = NA,
    AgeGroupAtBirthMother = 100*round(mean(!(Age == "NULL")),3),
    IMD_quintile = 100*round(mean(!((`Index of Multiple Deprivation Decile_v2` == "No Match") |
                                      (`Index of Multiple Deprivation Decile_v2` == "NULL"))),3),
    EthnicDescriptionMother = 100*round(mean(!(EthnicCategory == "NULL")),3),
    BroadEthnicityMother = 100*round(mean(!(EthnicCategory == "NULL")),3),
    FirstLanguageEnglishIndMother = 100*round(mean(!(PrimaryLanguage == "NULL")),3),
    EmploymentDescMother = NA,
    ComplexSocialFactors = NA,
    MentalHealthIssues = 100*round(mean(!(MentalHealth == "NULL")),3),
    SmokingStatusDesc = 100*round(mean(!(SmokingAtDelivery == "NULL")),3),
    AlcoholAtBooking = 100*round(mean(!(AlcoholAbuse == "NULL")),3),
    BMI_category =100*round(mean(!(`BMI>35` == "NULL")),3),
    NHS_Trust = 100*round(mean(!(LocationofDelivery == "NULL")),3),
    late_booking = 100*round(mean(!(GestationAtBookingWeeks == "NULL")),3),
    PreviousCaesareanSections = NA,
    PreviousLiveBirths = NA,
    PreviousStillBirths = NA,
    PreviousLossesLessThan24Weeks = NA,
    AnE_visits_pre_con = NA,
    AnE_visits_early_preg = NA,
    AnE_visits_preg = NA,
    DrugAbuse = 100*round(mean(!(DrugAbuse == "NULL"|is.na(DrugAbuse))),3),
    substanceAbuse = 100*round(mean(!(substanceAbuse == "NULL"|is.na(substanceAbuse))),3),
    SocialServicesInvolvement = 100*round(mean(!(SocialServicesInvolvement == "NULL"|
                                                   is.na(SocialServicesInvolvement))),3),
    DomesticAbuse = 100*round(mean(!(DomesticAbuse == "NULL"|is.na(DomesticAbuse))),3),
    LearningDisabilities = 100*round(mean(!(LearningDisabilities == "NULL"|
                                              is.na(LearningDisabilities))),3),
    Unsupported = 100*round(mean(!(Unsupported == "NULL"|is.na(Unsupported))),3),
    Homeless = 100*round(mean(!(Homeless == "NULL"|is.na(Homeless))),3),
    HousingIssues = 100*round(mean(!(HousingIssues == "NULL"|is.na(HousingIssues))),3),
    FinancialIssues= 100*round(mean(!(FinancialIssues == "NULL"|is.na(FinancialIssues))),3),
    GypsyTravelingFamilies = 100*round(mean(!(GypsyTravelingFamilies == "NULL"|
                                                is.na(GypsyTravelingFamilies))),3),
    sensoryAndPhysicalDis = 100*round(mean(!(sensoryAndPhysicalDis == "NULL"|
                                               is.na(sensoryAndPhysicalDis))),3),
    Citizenship = 100*round(mean(!(Citizenship == "NULL"|is.na(Citizenship))),3),
    ChildProtection = 100*round(mean(!(ChildProtection == "NULL"|is.na(ChildProtection))),3),
)

badger_complete_unnamed <- data.frame(t(badger_complete_t))
badger_complete_unnamed$variable = rownames(badger_complete_unnamed)

badger_complete <- rename(badger_complete_unnamed,
                        `BadgerNet completeness` = t.badger_complete_t.)

comb_completeness <- msds_complete %>%
  full_join(badger_complete) %>%
  select(c("variable", 
           "MSDS completeness", 
           "BadgerNet completeness"))

glimpse(comb_completeness)

write_xlsx(comb_completeness,
           "../data/outputs/data_completeness_comp.xlsx")