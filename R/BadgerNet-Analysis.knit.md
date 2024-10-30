---
title: "BadgerNet Analysis"
output: 
  pdf_document:
    toc: true
    number_sections: true
    
knit: (function(inputFile, encoding) {
      out_dir <- "../../../outputs/reports";
      rmarkdown::render(inputFile,
                        encoding=encoding,
                        output_dir=file.path(dirname(inputFile), out_dir))})
---



# BadgerNet

The BadgerNet dataset comes from the Birmingham Local Maternity and Neonatal System (LMNS). This dataset contains 39972 unique births from 2020-10-01 to 2023-04-01 with a total timespan of 912 days. 


## Reference Group

The risk ratios for each of the regressions calculated below are given relative 
to the following reference group. 


Table: Reference group for logistic regression.

|Variable              |Reference Value |
|:---------------------|:---------------|
|NumberOfBabies        |1               |
|AlcoholAbuse          |No              |
|substanceAbuse        |No              |
|Social Services       |No              |
|DomesticAbuse         |No              |
|LD                    |No              |
|Unsupported           |No              |
|MentalHealth          |No              |
|Homeless              |No              |
|HousingIssues         |No              |
|FinancialIssues       |No              |
|sensoryAndPhysicalDis |No              |
|Citizenship           |No              |
|SmokingAtDelivery     |No              |
|FGM                   |No              |
|Folic Acid Taken      |Yes             |
|BMI>35                |No              |
|Gestational_Diabetes  |No              |
|Consanguineous Union  |No              |
|IMD Quintile          |3+              |
|Mother Ethnicity      |White British   |
|Late booking          |No              |


## Variable Correlation Matrix



The following is a correlation matrix for our primary variables.


``` r
pdf(file = "../outputs/figures/correlation_2.pdf")
par(family="serif")
corrplot::corrplot(cor(badger2),
         method="square", 
         diag = FALSE, 
         addgrid.col = TRUE,
         type = 'lower',
         tl.col="black")
dev.off()
```

```
## pdf 
##   2
```


``` r
badger <- badger %>%
  mutate(
    Twins = case_when(
      NumberOfBabies == 2 ~ "Yes",
      TRUE ~ "No"
      ),
    `Domestic Abuse` = DomesticAbuse,
    `Mental Health Issue(s)` = MentalHealth,
    `Financial Issue(s)` = FinancialIssues,
    `Housing Issue(s)` = HousingIssues,
    `Sensory/Physical Disability` = sensoryAndPhysicalDis,
    `Alcohol Abuse` = AlcoholAbuse,
    `Substance Abuse` = substanceAbuse,
    `Smoking at Delivery` = SmokingAtDelivery,
    `Gestational Diabetes` = Gestational_Diabetes
    )

badger$Twins <- relevel(factor(badger$Twins), ref = "No")

all_variables = c("Twins","Age Group",
"Alcohol Abuse","Substance Abuse","Social Services",
"Domestic Abuse","LD","English Difficulties",
"Unsupported","Mental Health Issue(s)","Homeless","Housing Issue(s)",
"Financial Issue(s)","Sensory/Physical Disability","Citizenship",
"BMI>35","IMD Quintile","Mother Ethnicity",
"Smoking at Delivery","Gestational Diabetes",
"Consanguineous Union","Folic Acid Taken", "FGM", 
"Late booking")
```


# Basic regression

First we perform a basic regression with all variables of interest.

## Low-birth weight

```
## LowBirthWeight ~ Twins + `Age Group` + `Alcohol Abuse` + `Substance Abuse` + 
##     `Social Services` + `Domestic Abuse` + LD + `English Difficulties` + 
##     Unsupported + `Mental Health Issue(s)` + Homeless + `Housing Issue(s)` + 
##     `Financial Issue(s)` + `Sensory/Physical Disability` + Citizenship + 
##     `BMI>35` + `IMD Quintile` + `Mother Ethnicity` + `Smoking at Delivery` + 
##     `Gestational Diabetes` + `Consanguineous Union` + `Folic Acid Taken` + 
##     FGM + `Late booking`
## <environment: 0x00000172b1284128>
```

```
##                             Variable Importance Rank
## 1           `Smoking at Delivery`Yes       8.92    1
## 2        `Mother Ethnicity`Pakistani       8.20    2
## 3                           TwinsYes       7.46    3
## 4      `Mother Ethnicity`Bangladeshi       7.02    4
## 5           `Mother Ethnicity`Indian       6.92    5
## 6                        `BMI>35`Yes       5.44    6
## 7  `Mother Ethnicity`Black Caribbean       4.74    7
## 8      `Mother Ethnicity`Asian-Other       4.03    8
## 9            `Financial Issue(s)`Yes       3.94    9
## 10 `Mother Ethnicity`White and Asian       3.02   10
```





## Premature birth

```
## Premature ~ Twins + `Age Group` + `Alcohol Abuse` + `Substance Abuse` + 
##     `Social Services` + `Domestic Abuse` + LD + `English Difficulties` + 
##     Unsupported + `Mental Health Issue(s)` + Homeless + `Housing Issue(s)` + 
##     `Financial Issue(s)` + `Sensory/Physical Disability` + Citizenship + 
##     `BMI>35` + `IMD Quintile` + `Mother Ethnicity` + `Smoking at Delivery` + 
##     `Gestational Diabetes` + `Consanguineous Union` + `Folic Acid Taken` + 
##     FGM + `Late booking`
## <environment: 0x00000172c8006b58>
```

```
##                            Variable Importance Rank
## 1                          TwinsYes      33.58    1
## 2                 `Late booking`Yes       8.60    2
## 3          `Smoking at Delivery`Yes       6.24    3
## 4         `Mother Ethnicity`Unknown       5.92    4
## 5         `Gestational Diabetes`Yes       5.23    5
## 6  `Sensory/Physical Disability`Yes       5.13    6
## 7                    `Age Group`40+       4.75    7
## 8              `Social Services`Yes       4.03    8
## 9       `Mother Ethnicity`Pakistani       3.43    9
## 10             `Folic Acid Taken`No       3.04   10
```



## Stillbirth


```
## StillBirth ~ Twins + `Age Group` + `Alcohol Abuse` + `Substance Abuse` + 
##     `Social Services` + `Domestic Abuse` + LD + `English Difficulties` + 
##     Unsupported + `Mental Health Issue(s)` + Homeless + `Housing Issue(s)` + 
##     `Financial Issue(s)` + `Sensory/Physical Disability` + Citizenship + 
##     `BMI>35` + `IMD Quintile` + `Mother Ethnicity` + `Smoking at Delivery` + 
##     `Gestational Diabetes` + `Consanguineous Union` + `Folic Acid Taken` + 
##     FGM + `Late booking`
## <environment: 0x00000172c629a4e0>
```

```
## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

```
##                                     Variable Importance Rank
## 1                  `Mother Ethnicity`Unknown       3.47    1
## 2                          `Late booking`Yes       2.50    2
## 3  `Mother Ethnicity`White and Black African       2.21    3
## 4                            `IMD Quintile`1       2.13    4
## 5                   `Smoking at Delivery`Yes       2.06    5
## 6                             UnsupportedYes       1.97    6
## 7         `Mother Ethnicity`Eastern European       1.97    7
## 8          `Mother Ethnicity`Black Caribbean       1.93    8
## 9                `Mental Health Issue(s)`Yes       1.70    9
## 10                            `Age Group`40+       1.64   10
```



## Neonatal death


```
## NeonatalDeath ~ Twins + `Age Group` + `Alcohol Abuse` + `Substance Abuse` + 
##     `Social Services` + `Domestic Abuse` + LD + `English Difficulties` + 
##     Unsupported + `Mental Health Issue(s)` + Homeless + `Housing Issue(s)` + 
##     `Financial Issue(s)` + `Sensory/Physical Disability` + Citizenship + 
##     `BMI>35` + `IMD Quintile` + `Mother Ethnicity` + `Smoking at Delivery` + 
##     `Gestational Diabetes` + `Consanguineous Union` + `Folic Acid Taken` + 
##     FGM + `Late booking`
## <environment: 0x00000172c96b26c0>
```

```
## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

```
##                         Variable Importance Rank
## 1                       TwinsYes       5.98    1
## 2           `Folic Acid Taken`No       4.44    2
## 3    `Mother Ethnicity`Pakistani       3.82    3
## 4      `Mother Ethnicity`Unknown       3.38    4
## 5      `English Difficulties`Yes       2.97    5
## 6                 `Age Group`40+       2.74    6
## 7              `Late booking`Yes       2.65    7
## 8      `Gestational Diabetes`Yes       2.51    8
## 9  `Mother Ethnicity`Bangladeshi       2.43    9
## 10         `Housing Issue(s)`Yes       2.03   10
```



## VIF

![](C:\Users\TMPCDDES\OneDrive - Birmingham City Council\Documents\Main work\outputs\reports\BadgerNet-Analysis_files/figure-latex/vif-1.pdf)<!-- --> 

## Basic regression final results
\setlength{\LTpost}{0mm}
\begin{longtable}{lcccccc}
\toprule
 & \multicolumn{3}{c}{\textbf{Low birth weight}} & \multicolumn{3}{c}{\textbf{Premature Birth}} \\ 
\cmidrule(lr){2-4} \cmidrule(lr){5-7}
\textbf{Characteristic} & \textbf{OR}\textsuperscript{\textit{1}} & \textbf{95\% CI}\textsuperscript{\textit{1}} & \textbf{p-value} & \textbf{OR}\textsuperscript{\textit{1}} & \textbf{95\% CI}\textsuperscript{\textit{1}} & \textbf{p-value} \\ 
\midrule\addlinespace[2.5pt]
Twins &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 3.39 & 2.43, 4.62 & <0.001 & 27.2 & 22.5, 33.0 & <0.001 \\ 
Age Group &  &  &  &  &  &  \\ 
    20-29 & — & — &  & — & — &  \\ 
    Less than 20 & 1.16 & 0.81, 1.61 & 0.4 & 1.03 & 0.81, 1.28 & 0.8 \\ 
    30-39 & 0.98 & 0.87, 1.12 & 0.8 & 1.13 & 1.04, 1.22 & 0.004 \\ 
    40+ & 1.01 & 0.76, 1.32 & >0.9 & 1.49 & 1.26, 1.75 & <0.001 \\ 
Alcohol Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.15 & 0.48, 2.33 & 0.7 & 1.10 & 0.65, 1.78 & 0.7 \\ 
Substance Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.60 & 1.07, 2.32 & 0.018 & 1.38 & 1.04, 1.82 & 0.023 \\ 
Social Services &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.15 & 0.94, 1.40 & 0.2 & 1.30 & 1.14, 1.47 & <0.001 \\ 
Domestic Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.04 & 0.70, 1.49 & 0.8 & 1.24 & 0.98, 1.57 & 0.070 \\ 
LD &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.31 & 0.95, 1.78 & 0.092 & 1.15 & 0.93, 1.41 & 0.2 \\ 
English Difficulties &  &  &  &  &  &  \\ 
    NO & — & — &  & — & — &  \\ 
    Yes & 0.88 & 0.73, 1.07 & 0.2 & 0.94 & 0.83, 1.07 & 0.4 \\ 
Unsupported &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.83 & 0.47, 1.35 & 0.5 & 1.01 & 0.73, 1.37 & >0.9 \\ 
Mental Health Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.13 & 0.98, 1.31 & 0.089 & 1.13 & 1.04, 1.24 & 0.006 \\ 
Homeless &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.83 & 0.29, 1.88 & 0.7 & 1.10 & 0.61, 1.87 & 0.7 \\ 
Housing Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.15 & 0.89, 1.48 & 0.3 & 1.10 & 0.92, 1.30 & 0.3 \\ 
Financial Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.34 & 1.16, 1.55 & <0.001 & 1.07 & 0.97, 1.18 & 0.2 \\ 
Sensory/Physical Disability &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.94 & 0.71, 1.23 & 0.7 & 1.48 & 1.27, 1.72 & <0.001 \\ 
Citizenship &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.55 & 0.19, 1.22 & 0.2 & 0.98 & 0.58, 1.56 & >0.9 \\ 
BMI>35 &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.54 & 0.43, 0.67 & <0.001 & 0.96 & 0.86, 1.07 & 0.5 \\ 
IMD Quintile &  &  &  &  &  &  \\ 
    3+ & — & — &  & — & — &  \\ 
    1 & 1.11 & 0.95, 1.31 & 0.2 & 1.13 & 1.03, 1.25 & 0.013 \\ 
    2 & 1.08 & 0.89, 1.31 & 0.4 & 0.97 & 0.86, 1.09 & 0.6 \\ 
Mother Ethnicity &  &  &  &  &  &  \\ 
    White British & — & — &  & — & — &  \\ 
    Asian-Other & 1.96 & 1.40, 2.70 & <0.001 & 0.99 & 0.78, 1.24 & >0.9 \\ 
    Bangladeshi & 2.84 & 2.10, 3.77 & <0.001 & 1.26 & 1.01, 1.55 & 0.038 \\ 
    Black-Other & 1.46 & 0.74, 2.60 & 0.2 & 0.88 & 0.55, 1.33 & 0.6 \\ 
    Black African & 1.28 & 0.92, 1.74 & 0.13 & 0.96 & 0.79, 1.16 & 0.7 \\ 
    Black Caribbean & 2.21 & 1.57, 3.04 & <0.001 & 1.01 & 0.78, 1.28 & >0.9 \\ 
    Chinese & 2.11 & 1.03, 3.82 & 0.024 & 0.85 & 0.49, 1.37 & 0.5 \\ 
    Eastern European & 1.01 & 0.59, 1.63 & >0.9 & 0.95 & 0.71, 1.25 & 0.7 \\ 
    Indian & 2.45 & 1.89, 3.13 & <0.001 & 1.02 & 0.84, 1.22 & 0.9 \\ 
    Irish & 1.07 & 0.33, 2.57 & 0.9 & 0.68 & 0.32, 1.26 & 0.3 \\ 
    Middle Eastern & 1.86 & 1.13, 2.90 & 0.009 & 0.92 & 0.64, 1.29 & 0.6 \\ 
    Mixed-Other & 2.07 & 1.19, 3.36 & 0.006 & 0.78 & 0.49, 1.18 & 0.3 \\ 
    Other & 1.01 & 0.36, 2.22 & >0.9 & 0.54 & 0.28, 0.95 & 0.047 \\ 
    Pakistani & 2.12 & 1.77, 2.53 & <0.001 & 1.22 & 1.09, 1.37 & <0.001 \\ 
    Unknown & 0.63 & 0.19, 1.58 & 0.4 & 2.90 & 2.03, 4.10 & <0.001 \\ 
    White-Other & 0.87 & 0.62, 1.19 & 0.4 & 0.88 & 0.73, 1.04 & 0.14 \\ 
    White and Asian & 2.43 & 1.30, 4.16 & 0.003 & 0.79 & 0.45, 1.29 & 0.4 \\ 
    White and Black African & 0.44 & 0.02, 2.01 & 0.4 & 1.54 & 0.77, 2.78 & 0.2 \\ 
    White and Black Caribbean & 1.63 & 1.06, 2.39 & 0.018 & 1.21 & 0.93, 1.57 & 0.15 \\ 
Smoking at Delivery &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 2.37 & 1.96, 2.86 & <0.001 & 1.50 & 1.32, 1.71 & <0.001 \\ 
Gestational Diabetes &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.22 & 1.01, 1.46 & 0.035 & 1.36 & 1.21, 1.52 & <0.001 \\ 
Consanguineous Union &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.28 & 1.04, 1.57 & 0.019 & 1.00 & 0.85, 1.16 & >0.9 \\ 
Folic Acid Taken &  &  &  &  &  &  \\ 
    Yes & — & — &  & — & — &  \\ 
    No & 1.00 & 0.86, 1.17 & >0.9 & 1.16 & 1.05, 1.28 & 0.002 \\ 
FGM &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.44 & 0.98, 2.06 & 0.055 & 0.72 & 0.54, 0.94 & 0.020 \\ 
Late booking &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Unknown & 2.66 & 1.09, 5.56 & 0.017 & 1.84 & 1.07, 3.03 & 0.021 \\ 
    Yes & 1.18 & 0.95, 1.46 & 0.13 & 1.75 & 1.54, 1.98 & <0.001 \\ 
\bottomrule
\end{longtable}
\begin{minipage}{\linewidth}
\textsuperscript{\textit{1}}OR = Odds Ratio, CI = Confidence Interval\\
\end{minipage}
\setlength{\LTpost}{0mm}
\begin{longtable}{lcccccc}
\toprule
 & \multicolumn{3}{c}{\textbf{Stillbirth}} & \multicolumn{3}{c}{Neonatal Death} \\ 
\cmidrule(lr){2-4} \cmidrule(lr){5-7}
\textbf{Characteristic} & \textbf{OR}\textsuperscript{\textit{1}} & \textbf{95\% CI}\textsuperscript{\textit{1}} & \textbf{p-value} & \textbf{OR}\textsuperscript{\textit{1}} & \textbf{95\% CI}\textsuperscript{\textit{1}} & \textbf{p-value} \\ 
\midrule\addlinespace[2.5pt]
Twins &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 2.00 & 0.70, 4.47 & 0.13 & 5.59 & 3.04, 9.48 & <0.001 \\ 
Age Group &  &  &  &  &  &  \\ 
    20-29 & — & — &  & — & — &  \\ 
    Less than 20 & 0.88 & 0.30, 2.02 & 0.8 & 1.21 & 0.46, 2.63 & 0.7 \\ 
    30-39 & 0.99 & 0.72, 1.36 & >0.9 & 1.07 & 0.79, 1.44 & 0.7 \\ 
    40+ & 1.63 & 0.87, 2.85 & 0.10 & 2.08 & 1.19, 3.42 & 0.006 \\ 
Alcohol Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.00 & 0.00, 0.00 & >0.9 & 1.26 & 0.07, 5.79 & 0.8 \\ 
Substance Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.28 & 0.02, 1.32 & 0.2 & 0.00 & 0.00, 0.00 & >0.9 \\ 
Social Services &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.12 & 0.67, 1.80 & 0.7 & 0.85 & 0.49, 1.42 & 0.6 \\ 
Domestic Abuse &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.70 & 0.17, 1.94 & 0.6 & 1.88 & 0.76, 3.94 & 0.13 \\ 
LD &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.07 & 0.41, 2.30 & 0.9 & 1.31 & 0.54, 2.68 & 0.5 \\ 
English Difficulties &  &  &  &  &  &  \\ 
    NO & — & — &  & — & — &  \\ 
    Yes & 0.72 & 0.42, 1.19 & 0.2 & 0.44 & 0.25, 0.73 & 0.003 \\ 
Unsupported &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 2.34 & 0.90, 5.01 & 0.049 & 1.73 & 0.51, 4.32 & 0.3 \\ 
Mental Health Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.36 & 0.95, 1.94 & 0.089 & 1.04 & 0.73, 1.45 & 0.8 \\ 
Homeless &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.00 & 0.00, 0.00 & >0.9 & 1.68 & 0.09, 8.34 & 0.6 \\ 
Housing Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.98 & 0.47, 1.82 & >0.9 & 0.29 & 0.07, 0.81 & 0.042 \\ 
Financial Issue(s) &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.21 & 0.83, 1.74 & 0.3 & 1.36 & 0.95, 1.92 & 0.084 \\ 
Sensory/Physical Disability &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.78 & 0.33, 1.56 & 0.5 & 1.12 & 0.57, 1.98 & 0.7 \\ 
Citizenship &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 0.00 & 0.00, 0.00 & >0.9 & 0.00 & 0.00, 0.00 & >0.9 \\ 
BMI>35 &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.00 & 0.64, 1.51 & >0.9 & 1.16 & 0.76, 1.71 & 0.5 \\ 
IMD Quintile &  &  &  &  &  &  \\ 
    3+ & — & — &  & — & — &  \\ 
    1 & 1.61 & 1.05, 2.53 & 0.033 & 0.98 & 0.68, 1.43 & >0.9 \\ 
    2 & 1.36 & 0.81, 2.29 & 0.2 & 1.01 & 0.65, 1.57 & >0.9 \\ 
Mother Ethnicity &  &  &  &  &  &  \\ 
    White British & — & — &  & — & — &  \\ 
    Asian-Other & 0.88 & 0.26, 2.22 & 0.8 & 1.31 & 0.50, 2.87 & 0.5 \\ 
    Bangladeshi & 0.91 & 0.27, 2.28 & 0.9 & 2.36 & 1.11, 4.51 & 0.015 \\ 
    Black-Other & 2.14 & 0.51, 6.05 & 0.2 & 0.00 & 0.00, 0.00 & >0.9 \\ 
    Black African & 1.70 & 0.86, 3.18 & 0.11 & 1.08 & 0.48, 2.19 & 0.8 \\ 
    Black Caribbean & 2.10 & 0.92, 4.19 & 0.053 & 1.21 & 0.42, 2.75 & 0.7 \\ 
    Chinese & 0.00 & 0.00, 0.00 & >0.9 & 0.00 & 0.00, 0.00 & >0.9 \\ 
    Eastern European & 2.29 & 0.92, 4.91 & 0.049 & 0.92 & 0.22, 2.55 & 0.9 \\ 
    Indian & 1.17 & 0.48, 2.44 & 0.7 & 0.76 & 0.29, 1.64 & 0.5 \\ 
    Irish & 3.26 & 0.53, 10.6 & 0.10 & 0.00 & 0.00, 0.00 & >0.9 \\ 
    Middle Eastern & 0.95 & 0.15, 3.17 & >0.9 & 0.51 & 0.03, 2.39 & 0.5 \\ 
    Mixed-Other & 0.71 & 0.04, 3.27 & 0.7 & 0.00 & 0.00, 0.00 & >0.9 \\ 
    Other & 0.00 & 0.00, 0.00 & >0.9 & 1.82 & 0.30, 5.97 & 0.4 \\ 
    Pakistani & 1.15 & 0.71, 1.86 & 0.6 & 2.15 & 1.45, 3.19 & <0.001 \\ 
    Unknown & 5.75 & 1.89, 14.2 & <0.001 & 4.42 & 1.74, 9.92 & <0.001 \\ 
    White-Other & 0.82 & 0.33, 1.70 & 0.6 & 0.73 & 0.30, 1.50 & 0.4 \\ 
    White and Asian & 2.03 & 0.33, 6.59 & 0.3 & 3.06 & 0.74, 8.35 & 0.061 \\ 
    White and Black African & 5.11 & 0.82, 17.3 & 0.027 & 0.00 & 0.00, 0.00 & >0.9 \\ 
    White and Black Caribbean & 0.69 & 0.11, 2.21 & 0.6 & 0.36 & 0.02, 1.62 & 0.3 \\ 
Smoking at Delivery &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.65 & 1.01, 2.63 & 0.039 & 1.10 & 0.62, 1.83 & 0.7 \\ 
Gestational Diabetes &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.18 & 0.72, 1.84 & 0.5 & 0.47 & 0.25, 0.81 & 0.012 \\ 
Consanguineous Union &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.56 & 0.87, 2.68 & 0.12 & 1.58 & 1.00, 2.45 & 0.044 \\ 
Folic Acid Taken &  &  &  &  &  &  \\ 
    Yes & — & — &  & — & — &  \\ 
    No & 1.24 & 0.85, 1.76 & 0.3 & 2.04 & 1.48, 2.78 & <0.001 \\ 
FGM &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Yes & 1.25 & 0.54, 2.69 & 0.6 & 0.65 & 0.15, 2.05 & 0.5 \\ 
Late booking &  &  &  &  &  &  \\ 
    No & — & — &  & — & — &  \\ 
    Unknown & 0.00 & 0.00, 0.00 & >0.9 & 1.17 & 0.18, 4.42 & 0.8 \\ 
    Yes & 1.80 & 1.11, 2.81 & 0.013 & 1.81 & 1.14, 2.75 & 0.008 \\ 
\bottomrule
\end{longtable}
\begin{minipage}{\linewidth}
\textsuperscript{\textit{1}}OR = Odds Ratio, CI = Confidence Interval\\
\end{minipage}

We see that the result is not statistically significant for the following variables: AgeLessThan20, AlcoholAbuse, LD, DiffUndEnglish, Unsupported, Homeless, Citizenship, InterpreterRequired, FGM. Therefore, we remove these variables from our model.



Our maximised formula now becomes:

~, `Output:`, `Mother Ethnicity` + `IMD Quintile` + `Financial/Housing Issues` + `Substance Abuse` + `Social Services` + `Age Group` + Twins + `Mental Health Issue(s)` + `Sensory/Physical Disability` + `BMI>35` + `Gestational Diabetes` + `Smoking at Delivery` + `Folic Acid Taken` + `Late booking` + `> 4 missed apts` + `Consanguineous Union`

While our reduced formula is instead:

~, `Output:`, `Ethnicity Group` + `IMD Quintile` + `Financial/Housing Issues` + `Age Group` + Twins + `Mental Health Issue(s)` + `Smoking at Delivery` + `Folic Acid Taken` + `Late booking`

## Population description

First, lets calculate the proportions of each outcome for each variable


``` r
table1 <- badger %>%
  mutate(Outcome = case_when(
    Premature ~ "Premature",
    LowBirthWeight ~ "LBW",
    TRUE ~ "Normal"
  ),
  Outcome = factor(Outcome, levels = c("Normal", "LBW", "Premature"))
  ) %>%
  tbl_summary(
    include = all_important,
    by = "Outcome", # split table by group
  ) %>%
  #add_overall() %>% 
  #add_ci() %>%
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels() 
```

```
## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
## i Please use `all_of()` or `any_of()` instead.
##   # Was:
##   data %>% select(all_important)
## 
##   # Now:
##   data %>% select(all_of(all_important))
## 
## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

``` r
table1
```

```
## Table printed with `knitr::kable()`, not {gt}. Learn why at
## https://www.danieldsjoberg.com/gtsummary/articles/rmarkdown.html
## To suppress this message, include `message = FALSE` in code chunk header.
```



|**Variable**                    | **Normal**, N = 35,463 | **LBW**, N = 1,197 | **Premature**, N = 3,312 |
|:-------------------------------|:----------------------:|:------------------:|:------------------------:|
|__Mother Ethnicity__            |                        |                    |                          |
|White British                   |      15,411 (43%)      |     391 (33%)      |       1,435 (43%)        |
|Asian-Other                     |      1,106 (3.1%)      |     46 (3.8%)      |        93 (2.8%)         |
|Bangladeshi                     |      1,044 (2.9%)      |     62 (5.2%)      |        114 (3.4%)        |
|Black-Other                     |       333 (0.9%)       |     11 (0.9%)      |        23 (0.7%)         |
|Black African                   |      2,319 (6.5%)      |     70 (5.8%)      |        191 (5.8%)        |
|Black Caribbean                 |       808 (2.3%)       |     43 (3.6%)      |        81 (2.4%)         |
|Chinese                         |       252 (0.7%)       |     10 (0.8%)      |        17 (0.5%)         |
|Eastern European                |       700 (2.0%)       |     17 (1.4%)      |        62 (1.9%)         |
|Indian                          |      1,783 (5.0%)      |     83 (6.9%)      |        148 (4.5%)        |
|Irish                           |       167 (0.5%)       |      4 (0.3%)      |         9 (0.3%)         |
|Middle Eastern                  |       510 (1.4%)       |     21 (1.8%)      |        38 (1.1%)         |
|Mixed-Other                     |       305 (0.9%)       |     16 (1.3%)      |        24 (0.7%)         |
|Other                           |       242 (0.7%)       |      5 (0.4%)      |        12 (0.4%)         |
|Pakistani                       |      7,179 (20%)       |     331 (28%)      |        737 (22%)         |
|Unknown                         |       153 (0.4%)       |      4 (0.3%)      |        59 (1.8%)         |
|White-Other                     |      2,256 (6.4%)      |     42 (3.5%)      |        170 (5.1%)        |
|White and Asian                 |       204 (0.6%)       |     13 (1.1%)      |        16 (0.5%)         |
|White and Black African         |       97 (0.3%)        |     1 (<0.1%)      |        11 (0.3%)         |
|White and Black Caribbean       |       594 (1.7%)       |     27 (2.3%)      |        72 (2.2%)         |
|__IMD Quintile__                |                        |                    |                          |
|3+                              |      9,823 (28%)       |     248 (21%)      |        812 (25%)         |
|1                               |      19,089 (54%)      |     747 (62%)      |       1,960 (59%)        |
|2                               |      6,551 (18%)       |     202 (17%)      |        540 (16%)         |
|__Financial/Housing Issues__    |      6,952 (20%)       |     348 (29%)      |        807 (24%)         |
|__Substance Abuse__             |       318 (0.9%)       |     34 (2.8%)      |        72 (2.2%)         |
|__Social Services__             |      3,211 (9.1%)      |     174 (15%)      |        489 (15%)         |
|__Age Group__                   |                        |                    |                          |
|20-29                           |      14,588 (41%)      |     506 (42%)      |       1,284 (39%)        |
|Less than 20                    |       888 (2.5%)       |     39 (3.3%)      |        96 (2.9%)         |
|30-39                           |      18,350 (52%)      |     592 (49%)      |       1,714 (52%)        |
|40+                             |      1,637 (4.6%)      |     60 (5.0%)      |        218 (6.6%)        |
|__Twins__                       |       121 (0.3%)       |     44 (3.7%)      |        347 (10%)         |
|__Mental Health Issue(s)__      |      9,357 (26%)       |     354 (30%)      |       1,032 (31%)        |
|__Sensory/Physical Disability__ |      1,622 (4.6%)      |     58 (4.8%)      |        230 (6.9%)        |
|__BMI>35__                      |      4,569 (13%)       |     90 (7.5%)      |        438 (13%)         |
|__Gestational Diabetes__        |      3,425 (9.7%)      |     140 (12%)      |        422 (13%)         |
|__Smoking at Delivery__         |      2,623 (7.4%)      |     190 (16%)      |        419 (13%)         |
|__Folic Acid Taken__            |      29,417 (83%)      |     967 (81%)      |       2,611 (79%)        |
|__Late booking__                |                        |                    |                          |
|No                              |      33,072 (93%)      |    1,089 (91%)     |       2,914 (88%)        |
|Unknown                         |       93 (0.3%)        |      7 (0.6%)      |        22 (0.7%)         |
|Yes                             |      2,298 (6.5%)      |     101 (8.4%)     |        376 (11%)         |
|__> 4 missed apts__             |      1,892 (5.3%)      |     108 (9.0%)     |        211 (6.4%)        |
|__Consanguineous Union__        |      2,532 (7.1%)      |     132 (11%)      |        250 (7.5%)        |

``` r
table1 %>%
   as_gt() %>%
   gt::gtsave(filename = "../outputs/BN_int_reg_table.tex")
```


``` r
table2 <- badger %>%
  mutate(Outcome = case_when(
    StillBirth == 1 ~ "Stillbirth",
    NeonatalDeath == 1 ~ "Neonatal Death",
    TRUE ~ "Normal"
  ),
  Outcome = factor(Outcome, levels = c("Normal", "Stillbirth", "Neonatal Death"))
  ) %>%
  tbl_summary(
    include = less_variables,
    by = "Outcome", # split table by group
  ) %>%
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels() 
```

```
## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
## i Please use `all_of()` or `any_of()` instead.
##   # Was:
##   data %>% select(less_variables)
## 
##   # Now:
##   data %>% select(all_of(less_variables))
## 
## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

``` r
table2
```

```
## Table printed with `knitr::kable()`, not {gt}. Learn why at
## https://www.danieldsjoberg.com/gtsummary/articles/rmarkdown.html
## To suppress this message, include `message = FALSE` in code chunk header.
```



|**Variable**                 | **Normal**, N = 39,586 | **Stillbirth**, N = 178 | **Neonatal Death**, N = 208 |
|:----------------------------|:----------------------:|:-----------------------:|:---------------------------:|
|__Ethnicity Group__          |                        |                         |                             |
|White                        |      20,499 (52%)      |        82 (46%)         |          83 (40%)           |
|Asian                        |      12,857 (32%)      |        53 (30%)         |          95 (46%)           |
|Black                        |      3,835 (9.7%)      |        29 (16%)         |          15 (7.2%)          |
|Middle Eastern               |       566 (1.4%)       |        2 (1.1%)         |          1 (0.5%)           |
|Mixed                        |      1,369 (3.5%)      |        7 (3.9%)         |          4 (1.9%)           |
|Other                        |       257 (0.6%)       |         0 (0%)          |          2 (1.0%)           |
|Unknown                      |       203 (0.5%)       |        5 (2.8%)         |          8 (3.8%)           |
|__IMD Quintile__             |                        |                         |                             |
|3+                           |      10,804 (27%)      |        30 (17%)         |          49 (24%)           |
|1                            |      21,555 (54%)      |        118 (66%)        |          123 (59%)          |
|2                            |      7,227 (18%)       |        30 (17%)         |          36 (17%)           |
|__Financial/Housing Issues__ |      8,012 (20%)       |        47 (26%)         |          48 (23%)           |
|__Age Group__                |                        |                         |                             |
|20-29                        |      16,220 (41%)      |        75 (42%)         |          83 (40%)           |
|Less than 20                 |      1,012 (2.6%)      |        5 (2.8%)         |          6 (2.9%)           |
|30-39                        |      20,471 (52%)      |        84 (47%)         |          101 (49%)          |
|40+                          |      1,883 (4.8%)      |        14 (7.9%)        |          18 (8.7%)          |
|__Twins__                    |       493 (1.2%)       |        5 (2.8%)         |          14 (6.7%)          |
|__Mental Health Issue(s)__   |      10,633 (27%)      |        57 (32%)         |          53 (25%)           |
|__Smoking at Delivery__      |      3,190 (8.1%)      |        25 (14%)         |          17 (8.2%)          |
|__Folic Acid Taken__         |      32,719 (83%)      |        134 (75%)        |          142 (68%)          |
|__Late booking__             |                        |                         |                             |
|No                           |      36,744 (93%)      |        153 (86%)        |          178 (86%)          |
|Unknown                      |       120 (0.3%)       |         0 (0%)          |          2 (1.0%)           |
|Yes                          |      2,722 (6.9%)      |        25 (14%)         |          28 (13%)           |

``` r
table2 %>%
   as_gt() %>%
   gt::gtsave(filename = "../outputs/BN_final_reg_table.tex")
```

## Perform regression agian



## Display results







``` r
library(forestplot)
```

```
## Loading required package: grid
```

```
## Loading required package: checkmate
```

```
## Loading required package: abind
```

``` r
fplot <- function(model_tib, 
                  title = "",
                  part = 1) {

  
  # model_tib = tibble of the regression table
  model_tib["**95% CI** 2"] <- model_tib["**95% CI**"]
  model_tib <- tidyr::separate(model_tib, col = `**95% CI** 2`, into = c("lowerCI", "upperCI"), sep = ",")
  model_tib$`OR [95% CI]` = paste(
      model_tib$`**OR**`, 
      " [", model_tib$lowerCI, 
      "; ", model_tib$upperCI, "]",
      sep = ""
      )
  
  model_tib <- model_tib %>%
  mutate(
    `Odds Label`= case_when(
      is.na(`**OR**`) & 
        `**Characteristic**` %in% colnames(badger) ~ NA,
      is.na(`**OR**`) ~ "Ref",
      TRUE ~ as.character(`**OR**`)
    ),
    `Odds Ratio`= case_when(
      is.na(`**OR**`) & 
        `**Characteristic**` %in% colnames(badger) ~ NA,
      is.na(`**OR**`) ~ 1,
      as.numeric(`**OR**`) > 10 ~ NA,
      TRUE ~ as.numeric(`**OR**`)
    ),
    
    `lowerCI`= case_when(
      is.na(`lowerCI`) & 
        `**Characteristic**` %in% colnames(badger) ~ NA,
      is.na(`lowerCI`) ~ 1,
      TRUE ~ as.numeric(`lowerCI`)
    ),
    `upperCI`= case_when(
      is.na(`upperCI`) & 
        `**Characteristic**` %in% colnames(badger) ~ NA,
      is.na(`upperCI`) ~ 1,
      TRUE ~ as.numeric(`upperCI`)
    ),
    `OR [95% CI]` = case_when(
      is.na(`**OR**`) & 
        `**Characteristic**` %in% colnames(badger) ~ NA,
      is.na(`**OR**`) ~ "Reference",
      TRUE ~ `OR [95% CI]`
    )
  ) 
  

  if (part == 1) {
    # remove characteristic column

    model_tib_reduced <- model_tib %>% 
      select(c("**Characteristic**", "OR [95% CI]", "**p-value**"))
  } else {
    # Do nothing
    model_tib_reduced <- model_tib %>% 
      select(c("OR [95% CI]", "**p-value**"))
  } 
  
  # Prepare forest plot
  new_fp <- model_tib_reduced |> 
    forestplot(
    clip = c(-1, 6),
    graph.pos= 3 - part,
    mean= model_tib["Odds Ratio"], 
    zero=1,
    title=title,
    lower = model_tib["lowerCI"],
    upper = model_tib["upperCI"],
    boxsize=0.2,
    lwd.ci = 1.7,
    line.margin = unit(1, "mm"),
    lineheight = unit(6, "mm"),
    colgap = unit(5, "mm"),
    fn.ci_norm="fpDrawNormalCI",
    graphwidth=unit(0.2, "npc"),
    xticks = c(-1, 0,1, 2,3, 4,5, 6),
    is.summary = model_tib$`**Characteristic**` %in% colnames(badger),
    col=fpColors(box="#1f77b4", lines="#73B7E5", zero = "#D0D0D0"),
    txt_gp=fpTxtGp(label=gpar(cex=0.9),
                ticks=gpar(cex=0.8),
                xlab = gpar(cex=0.9),
                title=gpar(cex=1)),
    ) 
  if (part == 1) {

    new_fp <- new_fp |>
    fp_add_header(
      `**Characteristic**` = c(""),
      `OR [95% CI]` = c("OR [95% CI]"),
      `**p-value**` = c("p-value")
      ) |>
    fp_set_style(
      txt_gp = fpTxtGp(label = gpar(fontfamily = "serif")),
      )
  } else if (part == 2) {
    
    new_fp <- new_fp |>
    fp_add_header(
      `OR [95% CI]` = c("OR [95% CI]"),
      `**p-value**` = c("p-value")
      ) |>
    fp_set_style(
      txt_gp = fpTxtGp(label = gpar(fontfamily = "serif")),
      )
  }
  if (part == 1) {
      new_fp <- new_fp |>
    fp_set_style(align = "lccc")
  } else{
      new_fp <- new_fp |>
    fp_set_style(align = "ccc")
  }


  return(new_fp)
}
```




``` r
lbw_fp <- fplot(lbw_exp, title = "Low Birth Weight", part = 1)
prem_fp <- fplot(prem_exp, title = "Premature Birth", part = 2)

p1 <- ggplotify::grid2grob(print(lbw_fp)) 
p2 <- ggplotify::grid2grob(print(prem_fp))
both_big <- cowplot::plot_grid(
  p1,
  NA,
  p2,
  ncol = 3,
  rel_widths = c(1, -0.3, 1)
)
```

```
## Warning in as_grob.default(plot): Cannot convert object of class logical into a
## grob.
```

``` r
both_big
```

![](C:\Users\TMPCDDES\OneDrive - Birmingham City Council\Documents\Main work\outputs\reports\BadgerNet-Analysis_files/figure-latex/combine_forest_large-1.pdf)<!-- --> 

``` r
ggplot2::ggsave(both_big, 
                filename = "../outputs/figures/regression/reg_lbw_prem.pdf", 
                width = 12,
                height = 14)
```


``` r
sb_fp <- fplot(sb_exp, title = "Stillbirth", part = 1)
nd_fp <- fplot(nd_exp, title = "Neonatal Death", part = 2)

p1 <- ggplotify::grid2grob(print(sb_fp))
p2 <- ggplotify::grid2grob(print(nd_fp))

both_smalls <- cowplot::plot_grid(
  p1,
  NULL,
  p2,
  ncol = 3,
  rel_widths = c(1, -0.3, 1)
)
both_smalls
```

![](C:\Users\TMPCDDES\OneDrive - Birmingham City Council\Documents\Main work\outputs\reports\BadgerNet-Analysis_files/figure-latex/combine_forest_small-1.pdf)<!-- --> 

``` r
ggplot2::ggsave(both_smalls, 
                filename = "../outputs/figures/regression/reg_sb_nd.pdf", 
                width = 12,
                height = 7.8)
```
