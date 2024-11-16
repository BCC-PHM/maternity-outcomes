library(readxl)
library(dplyr)
library(ggplot2)

FT_data <- read_excel("../../data/general/FingerTipsData.xlsx") 

FT_data$IndicatorName = factor(
  FT_data$IndicatorName, 
  levels = c("Low birth weight of term babies",
             "Premature births (less than 37 weeks gestation)",
             "Stillbirth rate",
             "Neonatal mortality rate",
             "Infant mortality rate"))

BSol_data <- FT_data %>%
  mutate(
    AreaName = case_when(
      AreaName %in% c("Birmingham", "Solihull") ~ "BSol",
      TRUE ~ "England"
    )
  ) %>%
  group_by(AreaName, TimeperiodSortable, IndicatorName) %>%
  summarize(
    Count = sum(Count),
    Denominator = sum(Denominator)
  ) %>%
  mutate(
    Z = qnorm(0.975),
    a_prime = Count + 1,
    Value = 1000 * Count / Denominator,
    LowerCI95 = 1000 * Count * (1 - 1/(9*Count) - Z/3 * sqrt(1/a_prime))**3/Denominator,
    UpperCI95 = 1000 * a_prime * (1 - 1/(9*a_prime) + Z/3 * sqrt(1/a_prime))**3/Denominator
  )



LA_data <- FT_data %>%
  filter(AreaName %in% c("Birmingham", "Solihull"))%>%
  mutate(
    Value = 1000 * Count / Denominator,
   )

ggplot(BSol_data, aes(x = TimeperiodSortable, y = Value, color = AreaName)) + 
  geom_line(size = 1.05) +
  geom_point() +
  geom_ribbon(aes(ymin = LowerCI95, ymax = UpperCI95, fill = AreaName), 
              alpha = 0.5, colour = NA) + 
  geom_line(data = LA_data, aes(x = TimeperiodSortable, y = Value, linetype = AreaName), 
            color = "black", size = 0.9) +
  scale_linetype_manual(values=c("dashed", "dotted")) +
  scale_color_manual(values=c("#1f77b4", "darkgray")) +
  scale_fill_manual(values=c("#1f77b4", "darkgray")) +
  theme_bw() +
  facet_wrap(~IndicatorName, ncol = 1, scales = "free_y") +
  labs(
    y = "Crude Rate per 1000 Births*",
    x = "Year",
    linetype = "",
    fill = "",
    color = ""
  )+
  theme(
    strip.background = element_rect(fill="white"),
    text=element_text(size=14, family="serif")) +
  scale_x_continuous(
    breaks = c(20000000, 20050000, 20100000, 20150000, 20200000, 20250000),
    label = c(2000, 2005, 2010, 2015, 2020, 2025 ),
    limits = c(20000000, 20250000),
    expand = c(0,0)
    )

ggsave("../../outputs/figures/FT_plots.pdf", 
       width = 7, height = 7, dpi = 300)

# Print latest BSol and England numbers
latest_bsol_eng <- BSol_data %>%
  group_by(IndicatorName) %>%
  mutate(
    MaxDate = max(TimeperiodSortable)
  ) %>%
  filter(
    TimeperiodSortable == MaxDate
  ) %>%
  mutate(
    TimeperiodSortable = TimeperiodSortable/1e4
  ) %>%
  arrange(
    IndicatorName
  ) %>%
  select(
    IndicatorName,TimeperiodSortable, AreaName, Value, LowerCI95, UpperCI95
  )
latest_bsol_eng

# Print latest Birmingham and Solihull numbers
latest_brum_soli <- LA_data %>%
  group_by(IndicatorName) %>%
  mutate(
    MaxDate = max(TimeperiodSortable)
  ) %>%
  filter(
    TimeperiodSortable == MaxDate
  ) %>%
  mutate(
    TimeperiodSortable = TimeperiodSortable/1e4
  ) %>%
  arrange(
    IndicatorName
  ) %>%
  select(
    IndicatorName,#TimeperiodSortable, 
    AreaName, Value
  )
latest_brum_soli
