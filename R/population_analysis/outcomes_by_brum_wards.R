library(dplyr)
library(readxl)
library(writexl)

MSDSv1 <-read_excel("../../data/MSDS_v1.xlsx") %>%
  mutate(date_str = paste("01/", MonthOfBirthBaby, 
                          "/", YearOfBirthBaby, sep = ""),
         date = as.Date(date_str, format = "%d/%m/%Y"))

print(paste("MSDSv1 data spans from", min(MSDSv1$date),
            "to", max(MSDSv1$date)))

N_births <- MSDSv1 %>%
  count() %>%
  pull(n)

years_diff = as.numeric(max(MSDSv1$birth_date) - min(MSDSv1$birth_date))/365

print(paste("Birth rate of", 
            as.integer(N_births/years_diff),
            "per year"))

MSDSv1 <- NULL

outcomes <-read_excel("../../data/outcomes_by_LSOA.xlsx") 

LSOA_Ward <- read_excel("../../data/LSOA to 2018 wards weighted splits.xlsx") 

wardRates <- data.frame(matrix(ncol = 5, nrow = 0))
#provide column names
colnames(wardRates) <- c("2018 Ward Code",
                         "AllBirths",
                         "LiveBirths", 
                         "NormalBW",
                         "Premature")

ward_codes <- unique(LSOA_Ward$`2018 Ward Name`)

for (ward_i in ward_codes) {
  # Get all LSOAs in this ward
  LSOAs_i <- LSOA_Ward %>%
    filter(`2018 Ward Name` == ward_i)
  
  # Left join excess_STD
  outcomes_i <- LSOAs_i %>%
    left_join(outcomes, by = "LSOAMother2011") %>%
    mutate(AllBirths_i = AllBirths * `% of Ward (2011)`/100,
           NormalBW_i = NormalBW * `% of Ward (2011)`/100,
           LowBW_i = LowBW * `% of Ward (2011)`/100,
           Premature_i = Premature* `% of Ward (2011)`/100 ) %>%
    group_by(`2018 Ward Name`) %>%
    summarize(AllBirths = round(sum(AllBirths_i), digits = 2),
              NormalBW  = round(sum(NormalBW_i), digits = 2),
              LowBW     = round(sum(LowBW_i), digits = 2),
              Premature = round(sum(Premature_i), digits = 2))
    
  wardRates <- rbind(wardRates, outcomes_i)
}



total_births <- sum(wardRates$AllBirths)
print(paste("Total births:", total_births))

byWard_suppressed <- wardRates %>%
  mutate(AllBirths = case_when(AllBirths < 5 ~ "*",
                               TRUE ~ as.character(AllBirths))) %>%
  mutate(NormalBW = case_when(NormalBW < 5 ~ "*",
                              TRUE ~ as.character(NormalBW))) %>%
  mutate(LowBW = case_when(LowBW < 5 ~ "*",
                           TRUE ~ as.character(LowBW))) %>%
  mutate(Premature = case_when(Premature < 5 ~ "*",
                                   TRUE ~ as.character(Premature)))
write_xlsx(byWard_suppressed, "../../data/MSDSv1_OutcomesByWard_suppressed.xlsx")

# Check total is the same
# tot_STD_ward <- wardRates %>%
#   filter(Effect=="tot") %>%
#   summarise(tot = sum(`Excess std rate (x 100,000)`)) %>%
#   pull(tot)
# 
# if (tot_STD == tot_STD_ward) {
#   print("Total excess deaths is still the same.")
# } else{
#   print("Error: Total excess deaths has changed!!")
# }
# 
# write_xlsx(wardRates, "data/Temperature-related_mortality_by_ward.xlsx")




