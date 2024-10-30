library(fingertipsR)
library(dplyr)
library(data.table)
library(writexl)

IDs <- c(
  # Neonatal mortality rate
  92705,
  # Stillbirth rate
  92530,
  # Premature birth
  91743,
  # Low birth weight
  20101,
  # Infant mortality
  92196
)

all_data <- list()

for (i in 1:length(IDs)) {
  ID_i = IDs[[i]]
  print(ID_i)
  
  data_i <- fingertips_data(
    AreaTypeID = 502, 
    IndicatorID = ID_i
  ) %>%
    filter(
      AreaCode %in% c("E92000001","E08000029", "E08000025"),
      Sex == "Persons"
    )
  
  all_data[[i]] <- data_i
}

collected_data <- rbindlist(all_data)

write_xlsx(collected_data, "../../data/general/FingerTipsData.xlsx")