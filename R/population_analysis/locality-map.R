# BadgerNet BSol locality map

library(BSol.mapR)

source("~/Main work/MiscCode/r-regression-tools/r-regression-tools.R")

badger_load <- load_with_ref(
  "../../data/BadgerNet/BadgerNet-processed.parquet",
  seperate_ref_sheet = "../../data/BadgerNet/BadgerNet-RefGroups.xlsx",
  ref_sheet = "reference",
  add_colon = FALSE,
  return_ref = TRUE
)


data <- badger_load[[1]] %>%
  mutate(
    Locality = case_when(
      grepl("Solihull", `Local Area Profile`) ~ "Solihull",
      grepl("Birmingham", `Local Area Profile`) ~ gsub("Birmingham ", "", `Local Area Profile`),
      TRUE ~ `Local Area Profile`
    )
  )

locality_count <- data %>%
  count(Locality) %>%
  mutate(
    percentage = round(n/39972*100,1)
  ) %>%
  arrange(desc(percentage))

maternity_wards <- readxl::read_excel("../../data/general/maternity_wards.xlsx")

plot_colour = "#7d4fff" 
palette <- ggpubr::get_palette((c("white", plot_colour)), 20)

map <- plot_map(
  locality_count,
  value_header = "n",
  map_type = "Locality",
  map_title = "Number of Births in BadgerNet Data After Cleaning and Exclusion",
  style = "cont",
  breaks = c(0, 2000, 4000, 6000, 8000),
  palette = palette,
  credits_size = 0.8
)

map <- add_points(
  map,
  maternity_wards,
  size = 0.4,
  color = "Maternity Ward"
) +
  tmap::tm_layout(scale = 0.8)


save_map(
  map,
  save_name = "../../outputs/figures/locality-map.pdf",
  width = 6,
  height = 5
  )