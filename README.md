# BSol PHM Maternity Outcomes Project

Analysis of the wider determinants of birth outcomes in Birmingham and Solihull using maternity data provided by the Birmingham and Solihull United Maternity and Newborn
Partnership (BUMP) via BadgerNet. 

Four outcomes were studied using logistic regression: 
- Two intermediate outcomes:
	- premature birth
	- low birth weight
- Two final outcomes:
	- stillbirth
	- neonatal death

The fraction of each intermediate outcome attributable to ethnic and socioeconomic inequality was also calculated.

## R Code

- `preprocess-BN.R`: Data preprocessing code.
- `BadgerNet-Analysis.Rmd`: Primary analysis code.
- `locality-map.R`: Mapping geographical distribution of births.

## Python Code

- `AttributableFraction.py`: Calculating fraction of premature birth and LBW attributable to ethnicity and IMD.
- `RiskFactors.py`: Plotting ethnicity-IMD breakdown of risk factor prevalence.
- `OtherData.py`: Plotting historic infant mortality rates.
- `PosterLogReg.py`: Plotting logistic regression results for HACA 2023 poster.

## License

This repository is dual licensed under the [Open Government v3]([https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) & MIT. All code can outputs are subject to Crown Copyright.
