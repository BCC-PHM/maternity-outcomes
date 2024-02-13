/*
Query to join 3 main MSDS tables:
	- 401BabyDemographics
	- 101PregnancyBooking
	- 001MotherDemographics
*/


WITH 
motherDemo AS (
-- Get mother demographics
	SELECT DISTINCT 
		MotherPatientId,
		EthnicCategoryMother,
		Rank_IMD_Decile_2015,
		PostcodeDistrictMother,
		LSOAMother2011,
		AgeAtDeathMother,
		AgeRPEndDate,
		ElectoralWardMother,
		Person_ID_Mother
	FROM [EAT_Reporting_BSOL].[MSDS_V2].[VwMaternityServicesMSD001MotherDemog]
	),
booking AS (
	SELECT DISTINCT 
		AntenatalAppDate, 
		ComplexSocialFactorsInd,
		DisabilityIndMother,
		EDDAgreed,
		EDDMethodAgreed,
		EmploymentStatusMother,
		EmploymentStatusPartner,
		FolicAcidSupplement,
		GestAgeBooking,
		LangCode,
		Person_ID_Mother,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousLossesLessThan24Weeks,
		PreviousStillBirths,
		UniqPregID,
		UniqSubmissionID
	FROM [EAT_Reporting_BSOL].[MSDS_V2].[VwMaternityServicesMSD101PregnancyBooking]
),
babyDemo AS (
	SELECT DISTINCT
		BabyPatientID,
		UniqPregID,
		EthnicCategoryBaby,
		FetusPresentation,
		GestationLengthBirth,
		CONCAT(YearOfBirthBaby, '-', MonthOfBirthBaby)  AS PersonBirthDateBaby,
		PersonDeathDateBaby,
		BabyFirstFeedIndCode,
		Person_ID_Baby,
		Person_ID_Mother,
		PersonPhenSex,
		PregOutcome,
		SkinToSkinContact1HourInd
	FROM [EAT_Reporting_BSOL].[MSDS_V2].[VwMaternityServicesMSD401BabyDemographics]),

joinedWithDoubles AS (
	SELECT DISTINCT
		MotherPatientId,
		EthnicCategoryMother,
		Rank_IMD_Decile_2015,
		PostcodeDistrictMother,
		LSOAMother2011,
		AgeAtDeathMother,
		AgeRPEndDate,
		ElectoralWardMother,
		AntenatalAppDate, 
		ComplexSocialFactorsInd,
		DisabilityIndMother,
		EDDAgreed,
		EDDMethodAgreed,
		EmploymentStatusMother,
		EmploymentStatusPartner,
		FolicAcidSupplement,
		GestAgeBooking,
		LangCode,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousLossesLessThan24Weeks,
		PreviousStillBirths,
		UniqSubmissionID,
		BabyPatientID,
		EthnicCategoryBaby,
		FetusPresentation,
		GestationLengthBirth,
		PersonBirthDateBaby,
		PersonDeathDateBaby,
		BabyFirstFeedIndCode,
		Person_ID_Baby,
		PersonPhenSex,
		PregOutcome,
		SkinToSkinContact1HourInd,
		ROW_NUMBER() OVER (ORDER BY BabyPatientID) AS RowNum
	FROM motherDemo as md
	FULL JOIN booking as b
	ON md.Person_ID_Mother = b.Person_ID_Mother
	FULL JOIN babyDemo as bd
	ON md.Person_ID_Mother = bd.Person_ID_Mother
),
maxRowNum AS (
-- Get maximum row number for each baby ID to pick one entry for each baby
	SELECT Person_ID_Baby, MAX(RowNum) AS RowNum
	FROM joinedWithDoubles
	WHERE Person_ID_Baby IS NOT NULL
	GROUP BY Person_ID_Baby
),

doublesRemoved AS (
-- Join the rest of the data to the selected row numbers
	SELECT
		mrn.Person_ID_Baby,
		MotherPatientId,
		EthnicCategoryMother,
		Rank_IMD_Decile_2015,
		PostcodeDistrictMother,
		LSOAMother2011,
		AgeAtDeathMother,
		AgeRPEndDate,
		ElectoralWardMother,
		AntenatalAppDate, 
		ComplexSocialFactorsInd,
		DisabilityIndMother,
		EDDAgreed,
		EDDMethodAgreed,
		EmploymentStatusMother,
		EmploymentStatusPartner,
		FolicAcidSupplement,
		GestAgeBooking,
		LangCode,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousLossesLessThan24Weeks,
		PreviousStillBirths,
		UniqSubmissionID,
		BabyPatientID,
		EthnicCategoryBaby,
		FetusPresentation,
		GestationLengthBirth,
		PersonBirthDateBaby,
		PersonDeathDateBaby,
		BabyFirstFeedIndCode,
		PersonPhenSex,
		PregOutcome,
		SkinToSkinContact1HourInd
	FROM maxRowNum as mrn
	LEFT JOIN joinedWithDoubles as jwd
	ON jwd.RowNum = mrn.RowNum
),

apgar AS (
SELECT DISTINCT 
		ApgarScore,
		Person_ID_Baby
FROM [EAT_Reporting_BSOL].[MSDS_V2].[VwMaternityServicesMSD405CareActivityBaby]
WHERE ApgarScore IS NOT NULL AND 
	  Person_ID_Baby IS NOT NULL
	  ),

birthweight AS (
SELECT DISTINCT 
		BirthWeight,
		Person_ID_Baby
FROM [EAT_Reporting_BSOL].[MSDS_V2].[VwMaternityServicesMSD405CareActivityBaby]
WHERE BirthWeight IS NOT NULL AND 
	  Person_ID_Baby IS NOT NULL
	  ),
allIDs AS (
	SELECT Person_ID_Baby FROM apgar
	UNION
	SELECT Person_ID_Baby FROM birthweight
),

ApgarWeight AS (
	SELECT 
		id.Person_ID_Baby,
		ApgarScore,
		BirthWeight
	FROM allIDs AS id
	LEFT JOIN birthweight as bw
	ON id.Person_ID_Baby = bw.Person_ID_Baby
	LEFT JOIN apgar as ap
	ON id.Person_ID_Baby = ap.Person_ID_Baby
	-- Get rid of problem IDs
	WHERE 
		id.Person_ID_Baby <> 'X7ZOYA4L2SQ74QY' AND
		id.Person_ID_Baby <> 'R8AHIY58MWJ0M3F' AND
		id.Person_ID_Baby <> 'RVIBOZUDHSA880L'
	),

finalJoin AS (
	SELECT
		dr.Person_ID_Baby,
		MotherPatientId,
		EthnicCategoryMother,
		CAST(SUBSTRING(Rank_IMD_Decile_2015, 1, 2) AS int) Rank_IMD_Decile_2015,
		PostcodeDistrictMother,
		LSOAMother2011,
		AgeAtDeathMother,
		AgeRPEndDate,
		ElectoralWardMother,
		AntenatalAppDate, 
		ComplexSocialFactorsInd,
		DisabilityIndMother,
		EDDAgreed,
		EDDMethodAgreed,
		EmploymentStatusMother,
		EmploymentStatusPartner,
		FolicAcidSupplement,
		GestAgeBooking,
		LangCode,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousLossesLessThan24Weeks,
		PreviousStillBirths,
		UniqSubmissionID,
		BabyPatientID,
		EthnicCategoryBaby,
		FetusPresentation,
		PersonBirthDateBaby,
		PersonDeathDateBaby,
		BabyFirstFeedIndCode,
		SkinToSkinContact1HourInd,
		PersonPhenSex,
		PregOutcome,
		ApgarScore,
		BirthWeight,
		GestationLengthBirth
	FROM doublesRemoved AS dr
	LEFT JOIN ApgarWeight aw
	ON dr.Person_ID_Baby = aw.Person_ID_Baby)

--DROP TABLE ##MSDSv2
SELECT *
INTO ##MSDSv2
FROM finalJoin
