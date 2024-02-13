/*
Linking in-patient records with diagnosisCode = F10 to F19 to MSDSv2 for
dual diagnosis deep dive.
*/

-- Number of months from birth to collect F1* codes
DECLARE @TimePeriodMonths int = 1;
DECLARE @MaxAdmissionMonths int = 12*2022 + 6;
DECLARE @MinAdmissionMonths int = 12*2015;

WITH 
episodes AS (
	SELECT 
		NHSNumber,
		AdmissionDate,
		EpisodeId
	FROM [EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodes]
	),

-- Get all episodes with any F1% code
allF1codes AS (
SELECT
	EpisodeId,
	1 AS Any_F1_Code
FROM [EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational]
WHERE DiagnosisCode LIKE 'F1%'
GROUP BY EpisodeId
), 

-- Get all episodes with any F17% code
F17codes AS (
SELECT 
	EpisodeId,
	1 AS F17_Code
FROM [EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational]
WHERE DiagnosisCode LIKE 'F17%'
GROUP BY EpisodeId
), 

-- Get all episodes with any F20 - F99 code
F20PlusCodes AS (
SELECT 
	EpisodeId,
	1 AS F20plus_Code
FROM [EAT_Reporting_BSOL].[SUS].[VwInpatientEpisodesDiagnosisRelational]
WHERE 
	(DiagnosisCode LIKE 'F2%' OR 
	 DiagnosisCode LIKE 'F3%' OR
	 DiagnosisCode LIKE 'F4%' OR
	 DiagnosisCode LIKE 'F5%' OR
	 DiagnosisCode LIKE 'F6%' OR
	 DiagnosisCode LIKE 'F7%' OR
	 DiagnosisCode LIKE 'F8%' OR
	 DiagnosisCode LIKE 'F9%') AND
	 DiagnosisCode NOT LIKE 'F43%'
GROUP BY EpisodeId
), 

inpatients AS (
	SELECT 
		NHSNumber,
		AdmissionDate,
		e.EpisodeId,
		Any_F1_Code,
		F17_Code,
		F20plus_Code
	FROM episodes AS e
	LEFT JOIN allF1codes AS allF
	ON e.EpisodeId = allF.EpisodeId
	LEFT JOIN F17codes AS F17
	ON e.EpisodeId = F17.EpisodeId
	LEFT JOIN F20PlusCodes AS F20p
	ON e.EpisodeId = F20p.EpisodeId
	WHERE 
		Any_F1_Code = 1 OR 
		F17_Code = 1 OR
		F20plus_Code = 1
),

f20Unique AS (
	SELECT DISTINCT 
		NHSNumber,
		F20plus_Code
	FROM inpatients
),

roughJoin AS (
SELECT
		MotherPatientId,
		BabyPatientID,
		PersonBirthDateBaby,
		AdmissionDate,
		12*CAST(SUBSTRING(PersonBirthDateBaby, 1, 4) AS int) + 
		   CAST(SUBSTRING(PersonBirthDateBaby, 6, 7) AS int) AS BirthDateMonths,
		(12*CAST(SUBSTRING(PersonBirthDateBaby, 1, 4) AS int) + 
		   CAST(SUBSTRING(PersonBirthDateBaby, 6, 7) AS int) -
		   12*YEAR(AdmissionDate) - MONTH(AdmissionDate)) AS DateDiff_months,
		GestationLengthBirth,
		PregOutcome,
		Any_F1_Code,
		F17_Code
	FROM ##MSDSv2 AS msds
	LEFT JOIN inpatients AS inpat
	ON msds.MotherPatientId = inpat.NHSNumber

	WHERE 
		PersonBirthDateBaby IS NOT NULL AND 
		-- Resrict to definded time period before latest in-patient diagnosis
		12*CAST(SUBSTRING(PersonBirthDateBaby, 1, 4) AS int) + 
		   CAST(SUBSTRING(PersonBirthDateBaby, 6, 7) AS int) < 
		   @MaxAdmissionMonths - @TimePeriodMonths AND
		--- Greater than minimum in-patients plus def time period
		12*CAST(SUBSTRING(PersonBirthDateBaby, 1, 4) AS int) + 
		   CAST(SUBSTRING(PersonBirthDateBaby, 6, 7) AS int) > 
		@MinAdmissionMonths + @TimePeriodMonths
),
dateWindow AS (
	SELECT
		BabyPatientID,
		SUM(Any_F1_Code)/SUM(Any_F1_Code) AS Any_F1_Code,
		SUM(F17_Code)/SUM(F17_Code) As F17_Code
	FROM roughJoin
	WHERE DateDiff_months <= @TimePeriodMonths AND 
	      DateDiff_months >= -@TimePeriodMonths
	GROUP BY BabyPatientID
),
MSDS_dual AS (
	SELECT 
		--MotherPatientId,
		--ms.BabyPatientID,
		PersonBirthDateBaby,
		GestationLengthBirth,
		PregOutcome,
		ApgarScore,
		BirthWeight,
		EthnicCategoryMother,
		Rank_IMD_Decile_2015,
		GestAgeBooking,
		ComplexSocialFactorsInd,
		LangCode,
		EmploymentStatusMother,
		Any_F1_Code,
		F17_Code,
		f20.F20plus_Code
	FROM ##MSDSv2 AS ms
	LEFT JOIN dateWindow AS d
		ON ms.BabyPatientID = d.BabyPatientID
	LEFT JOIN f20Unique AS f20
		ON ms.MotherPatientId = f20.NHSNumber
	WHERE 
	-- Restrict to cases that actually have something useful
		GestationLengthBirth IS NOT NULL OR
		PregOutcome IS NOT NULL OR
		ApgarScore IS NOT NULL OR 
		BirthWeight IS NOT NULL
)

SELECT *
FROM MSDS_dual
--WHERE Any_F1_Code = 1

