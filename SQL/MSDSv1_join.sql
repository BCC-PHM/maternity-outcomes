WITH 
baby_doubles AS (
	/*
	Get all relevent data from baby demographics and generate row number for 
	each entry
	*/
	SELECT DISTINCT 
				UniquePregID, 
				MSDS_ID_Baby,
				MSDS_ID_Mother,
				NHSNumberStatusBaby,
				PersonPhenotypicSex,
				PersonDeathDateTimeBaby,
				BirthWeight,
				GestationLengthBirth,
				DeliveryMethodBaby,
				WaterDeliveryInd,
				ApgarScore5,
				SiteCodeActualDelivery,
				PlaceTypeActualDelivery,
				PlaceTypeActualMidwifery,
				BabyFirstFeedDateTime,
				BabyFirstFeedBreastMilkStatus,
				BabyBreastMilkStatusDischarge,
				SkinToSkinContact1Hour,
				YearOfBirthBaby,
				MonthOfBirthBaby,
				DayOfBirthBaby,
				MerOfBirthBaby,
				AgeAtBirthMother,
				BabyFirstFeed,
				ROW_NUMBER() OVER (ORDER BY MSDS_ID_Baby, MSDS_ID_Mother) AS RowNum
			FROM [EAT_Reporting_BSOL].[Maternity_MSDS].[vw_tbMaternityServicesMAT502BabyDemogAndBirth]),
baby_rows AS (
	/*
	Get maximum row number for each baby to eliminate doubles
	*/
	SELECT
		MSDS_ID_Baby,
		MSDS_ID_Mother,
		MAX(RowNum) AS maxRowNum
	FROM baby_doubles
	GROUP BY MSDS_ID_Baby, MSDS_ID_Mother
),

baby AS (
	/*
	Join baby data with doubles to max row numbers to eliminate doubles

	N = 31609 records
	*/
	SELECT
		UniquePregID, 
		baby_rows.MSDS_ID_Baby,
		baby_rows.MSDS_ID_Mother,
		NHSNumberStatusBaby,
		PersonPhenotypicSex,
		PersonDeathDateTimeBaby,
		BirthWeight,
		GestationLengthBirth,
		DeliveryMethodBaby,
		WaterDeliveryInd,
		ApgarScore5,
		SiteCodeActualDelivery,
		PlaceTypeActualDelivery,
		PlaceTypeActualMidwifery,
		BabyFirstFeedDateTime,
		BabyFirstFeedBreastMilkStatus,
		BabyBreastMilkStatusDischarge,
		SkinToSkinContact1Hour,
		YearOfBirthBaby,
		MonthOfBirthBaby,
		DayOfBirthBaby,
		MerOfBirthBaby,
		AgeAtBirthMother,
		BabyFirstFeed
	FROM baby_rows
	LEFT JOIN baby_doubles
	ON baby_rows.maxRowNum = baby_doubles.RowNum),

mother_doubles AS (
	/*
	Get all relevent data from mother demographics and generate row number for 
	each entry
	*/
	SELECT DISTINCT
		NHSNumberStatusMother, 
		EthnicCategoryMother,
		PersonDeathDateTimeMother,
		RecordNumber,
		MAT001_ID,
		OrgCodeProvider,
		OrgCodeCCGRes,
		MSDS_ID_Mother,
		UniquePregID,
		AgeMotherStartRP,
		AgeMotherEndRP,
		AgeAtDeathMother,
		PostcodeDistrictMother,
		LSOAMother2011,
		LAD_UAMother,
		CCG_ResMother,
		CountyMother,
		ElectoralWardMother,
		ROW_NUMBER() OVER (ORDER BY MSDS_ID_Mother, UniquePregID) AS RowNum
	FROM [EAT_Reporting_BSOL].[Maternity_MSDS].[vw_tbMaternityServicesMAT001MotherDemog] 
	),

mother_rows AS (
	/*
	Get maximum row number for each mother and pregnancy combo
	to eliminate doubles
	*/
	SELECT 
		MSDS_ID_Mother,
		UniquePregID,
		MAX(RowNum) AS maxRowNum
	FROM mother_doubles
	GROUP BY 
		MSDS_ID_Mother,
		UniquePregID
), 

mother AS (
	/*
	Join mother data with doubles to max row numbers to eliminate doubles
	*/
	SELECT
		NHSNumberStatusMother, 
		EthnicCategoryMother,
		PersonDeathDateTimeMother,
		RecordNumber,
		MAT001_ID,
		OrgCodeProvider,
		OrgCodeCCGRes,
		mother_rows.MSDS_ID_Mother,
		mother_rows.UniquePregID,
		AgeMotherStartRP,
		AgeMotherEndRP,
		AgeAtDeathMother,
		PostcodeDistrictMother,
		LSOAMother2011,
		LAD_UAMother,
		CCG_ResMother,
		CountyMother,
		ElectoralWardMother
		FROM mother_rows
		LEFT JOIN mother_doubles
		ON mother_rows.maxRowNum = mother_doubles.RowNum
),


booking_doubles AS (
	/*
	Get all relevent data from pregnancy booking and generate row number for 
	each entry
	*/
	SELECT DISTINCT
		UniquePregID,
		EDDAgreed,
		EDDMethodAgreed,
		--PregnancyFirstContactDate,
		PregnancyFirstContactCareProfessionalType,
		LastMenstrualPeriodDate,
		PhysicalDisabilityStatusIndMother,
		FirstLanguageEnglishIndMother,
		EmploymentStatusMother,
		SupportStatusMother,
		EmploymentStatusPartner,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousStillBirths,
		PreviousLossesLessThan24Weeks,
		SubstanceUseStatus,
		SmokingStatus,
		CigarettesPerDay,
		AlcoholUnitsPerWeek,
		FolicAcidSupplement,
		MHPredictionDetectionIndMother,
		PersonWeight,
		PersonHeight,
		ComplexSocialFactorsInd,
		OrgCodeProvider,
		MSDS_ID_Mother,
		AgeAtBookingMother,
		LeadAnteProvider,
		ROW_NUMBER() OVER (ORDER BY MSDS_ID_Mother, UniquePregID) AS RowNum
	FROM [EAT_Reporting_BSOL].[Maternity_MSDS].[vw_tbMaternityServicesMAT101Booking]
),


booking_rows AS (
	/*
	Get maximum row number for each booking to eliminate doubles
	*/
	SELECT
		UniquePregID,
		MAX(RowNum) as maxRowNum
	FROM booking_doubles
	GROUP BY UniquePregID
),

first_contact AS (
	/*
	Get contact date
	*/
	SELECT
		UniquePregID,
		min(PregnancyFirstContactDate) AS PregnancyFirstContactDate
	FROM [EAT_Reporting_BSOL].[Maternity_MSDS].[vw_tbMaternityServicesMAT101Booking]
	GROUP BY UniquePregID
),
booking AS (
	/*
	Join booking data with doubles to max row numbers to eliminate doubles
	*/
	SELECT 
		booking_rows.UniquePregID,
		EDDAgreed,
		EDDMethodAgreed,
		f.PregnancyFirstContactDate,
		PregnancyFirstContactCareProfessionalType,
		LastMenstrualPeriodDate,
		PhysicalDisabilityStatusIndMother,
		FirstLanguageEnglishIndMother,
		EmploymentStatusMother,
		SupportStatusMother,
		EmploymentStatusPartner,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousStillBirths,
		PreviousLossesLessThan24Weeks,
		SubstanceUseStatus,
		SmokingStatus,
		CigarettesPerDay,
		AlcoholUnitsPerWeek,
		FolicAcidSupplement,
		MHPredictionDetectionIndMother,
		PersonWeight,
		PersonHeight,
		ComplexSocialFactorsInd,
		OrgCodeProvider,
		MSDS_ID_Mother,
		AgeAtBookingMother,
		LeadAnteProvider
	FROM booking_rows
	LEFT JOIN booking_doubles
		ON booking_rows.maxRowNum = booking_doubles.RowNum
	LEFT JOIN first_contact AS f
		ON booking_rows.UniquePregID = f.UniquePregID),

MSDS_joined AS (
	/*
	Join the three tables on Mother ID and pregnancy ID
	*/
	SELECT DISTINCT
		bridge.PatientId AS MotherNHSNumber,
		baby.UniquePregID, 
		baby.MSDS_ID_Baby,
		baby.MSDS_ID_Mother,
		NHSNumberStatusBaby,
		PersonPhenotypicSex,
		PersonDeathDateTimeBaby,
		BirthWeight,
		GestationLengthBirth,
		DeliveryMethodBaby,
		WaterDeliveryInd,
		ApgarScore5,
		SiteCodeActualDelivery,
		PlaceTypeActualDelivery,
		PlaceTypeActualMidwifery,
		BabyFirstFeedDateTime,
		BabyFirstFeedBreastMilkStatus,
		BabyBreastMilkStatusDischarge,
		SkinToSkinContact1Hour,
		YearOfBirthBaby,
		MonthOfBirthBaby,
		DayOfBirthBaby,
		MerOfBirthBaby,
		CONVERT(
			datetime, 
			CONCAT(
				YearOfBirthBaby, 
				'-', 
				MonthOfBirthBaby,
				'-15')) AS birth_date,
		CONVERT(
			datetime, 
			CONCAT(
				YearOfBirthBaby, 
				'-', 
				MonthOfBirthBaby,
				'-15')
			) + 275 - GestationLengthBirth AS expected_date,
		CONVERT(
			datetime, 
			CONCAT(
				YearOfBirthBaby, 
				'-', 
				MonthOfBirthBaby,
				'-15')
			) - GestationLengthBirth AS pred_conception_date,
		AgeAtBirthMother,
		BabyFirstFeed,
		NHSNumberStatusMother, 
		EthnicCategoryMother,
		PersonDeathDateTimeMother,
		OrgCodeCCGRes,
		AgeMotherStartRP,
		AgeMotherEndRP,
		AgeAtDeathMother,
		PostcodeDistrictMother,
		LSOAMother2011,
		LAD_UAMother,
		CCG_ResMother,
		CountyMother,
		ElectoralWardMother,
		-- from booking --
		EDDAgreed,
		EDDMethodAgreed,
		PregnancyFirstContactDate,
		PregnancyFirstContactCareProfessionalType,
		LastMenstrualPeriodDate,
		PhysicalDisabilityStatusIndMother,
		FirstLanguageEnglishIndMother,
		EmploymentStatusMother,
		SupportStatusMother,
		EmploymentStatusPartner,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousStillBirths,
		PreviousLossesLessThan24Weeks,
		SubstanceUseStatus,
		SmokingStatus,
		CigarettesPerDay,
		AlcoholUnitsPerWeek,
		FolicAcidSupplement,
		MHPredictionDetectionIndMother,
		PersonWeight,
		PersonHeight,
		ComplexSocialFactorsInd,
		AgeAtBookingMother,
		LeadAnteProvider
		FROM baby
		LEFT JOIN mother 
			ON baby.UniquePregID = mother.UniquePregID AND
			   baby.MSDS_ID_Mother = mother.MSDS_ID_Mother
		LEFT JOIN booking
			ON baby.UniquePregID = booking.UniquePregID AND
			   baby.MSDS_ID_Mother = booking.MSDS_ID_Mother
		LEFT JOIN [EAT_Reporting_BSOL].[Maternity_MSDS].[vw_tbMaternityServicesBridging] AS bridge
			ON baby.MSDS_ID_Mother = bridge.PERSON_INDEX_ID
		WHERE CONCAT(YearOfBirthBaby, '-', MonthOfBirthBaby,'-15') > '2017-06-15'
),
AnE_Dates 
AS (
	SELECT 
	DISTINCT
	NHSNumber,
	CONVERT(
		datetime, 
		CONCAT(
			YEAR(ArrivalDateTime), '-',
			MONTH(ArrivalDateTime), '-',
			DAY(ArrivalDateTime))
		) AS AnE_Date
	FROM [EAT_Reporting_BSOL].[SUS].[VwAE]
	WHERE NHSNumber IS NOT NULL
),

pre_conception AS
(
	SELECT 
		MotherNHSNumber,
		MSDS_ID_Baby,
		COUNT(*) AS AnE_visits_pre_con
	FROM MSDS_joined AS m
	LEFT JOIN AnE_Dates AS a
	ON m.MotherNHSNumber = a.NHSNumber
	WHERE 
		AnE_Date < pred_conception_date AND 
		AnE_Date >= pred_conception_date - 365
	GROUP BY 
		MotherNHSNumber,
		MSDS_ID_Baby
),
early_preg AS
(
	SELECT 
		MotherNHSNumber,
		MSDS_ID_Baby,
		COUNT(*) AS AnE_visits_early_preg
	FROM MSDS_joined AS m
	LEFT JOIN AnE_Dates AS a
	ON m.MotherNHSNumber = a.NHSNumber
	WHERE 
		AnE_Date < pred_conception_date + 12*7 AND 
		AnE_Date >= pred_conception_date
	GROUP BY 
		MotherNHSNumber,
		MSDS_ID_Baby
),
preg AS
(
	SELECT 
		MotherNHSNumber,
		MSDS_ID_Baby,
		COUNT(*) AS AnE_visits_preg
	FROM MSDS_joined AS m
	LEFT JOIN AnE_Dates AS a
	ON m.MotherNHSNumber = a.NHSNumber
	WHERE 
		AnE_Date < birth_date AND 
		AnE_Date > pred_conception_date
	GROUP BY 
		MotherNHSNumber,
		MSDS_ID_Baby
),
ANE_joined AS 
(
	SELECT
		a.MSDS_ID_Baby,
		AnE_visits_pre_con,
		AnE_visits_early_preg,
		AnE_visits_preg
	FROM
		pre_conception AS a
	LEFT JOIN early_preg AS b
		ON a.MSDS_ID_Baby = b.MSDS_ID_Baby
	LEFT JOIN preg AS c
		ON a.MSDS_ID_Baby = c.MSDS_ID_Baby
),

all_joined AS 
(
	SELECT
		MotherNHSNumber,
		UniquePregID, 
		MSDS_joined.MSDS_ID_Baby,
		MSDS_ID_Mother,
		NHSNumberStatusBaby,
		PersonPhenotypicSex,
		PersonDeathDateTimeBaby,
		BirthWeight,
		GestationLengthBirth,
		DeliveryMethodBaby,
		WaterDeliveryInd,
		ApgarScore5,
		SiteCodeActualDelivery,
		PlaceTypeActualDelivery,
		PlaceTypeActualMidwifery,
		BabyFirstFeedDateTime,
		BabyFirstFeedBreastMilkStatus,
		BabyBreastMilkStatusDischarge,
		SkinToSkinContact1Hour,
		birth_date,
		expected_date,
		pred_conception_date,

		AgeAtBirthMother,
		BabyFirstFeed,
		NHSNumberStatusMother, 
		EthnicCategoryMother,
		-- Get ethncity Description
		CASE
			WHEN EthnicCategoryMother = 'A' THEN 'British'
			WHEN EthnicCategoryMother = 'B' THEN 'Irish'
			WHEN EthnicCategoryMother = 'C' THEN 'Any other White background'
			WHEN EthnicCategoryMother = 'D' THEN 'White and Black Caribbean'
			WHEN EthnicCategoryMother = 'E' THEN 'White and Black African'
			WHEN EthnicCategoryMother = 'F' THEN 'White and Asian'
			WHEN EthnicCategoryMother = 'G' THEN 'Any other mixed background'
			WHEN EthnicCategoryMother = 'H' THEN 'Indian'
			WHEN EthnicCategoryMother = 'J' THEN 'Pakistani'
			WHEN EthnicCategoryMother = 'K' THEN 'Bangladeshi'
			WHEN EthnicCategoryMother = 'L' THEN 'Any other Asian background'
			WHEN EthnicCategoryMother = 'M' THEN 'Caribbean'
			WHEN EthnicCategoryMother = 'N' THEN 'African'
			WHEN EthnicCategoryMother = 'P' THEN 'Any other Black background'
			WHEN EthnicCategoryMother = 'R' THEN 'Chinese'
			WHEN EthnicCategoryMother = 'S' THEN 'Any other ethnic group'
			WHEN EthnicCategoryMother = 'Z' THEN 'Not stated'
			WHEN EthnicCategoryMother = '99' THEN 'Not known'
		END AS EthnicDescriptionMother,
		-- Get broad ethncity Description
		CASE
			WHEN EthnicCategoryMother IN ('A','B','C') THEN 'White'
			WHEN EthnicCategoryMother IN ('D','E','F','G') THEN 'Mixed'
			WHEN EthnicCategoryMother IN ('H','J','K','L') THEN 'Asian'
			WHEN EthnicCategoryMother IN ('M','N','P') THEN 'Black'
			WHEN EthnicCategoryMother IN ('R', 'S') THEN 'Other'
			WHEN EthnicCategoryMother IN ('Z', '99') THEN 'Unknown'
		END AS BroadEthnicityMother,
		PersonDeathDateTimeMother,
		OrgCodeCCGRes,
		AgeMotherStartRP,
		AgeMotherEndRP,
		AgeAtDeathMother,
		PostcodeDistrictMother,
		LSOAMother2011,
		LAD_UAMother,
		CCG_ResMother,
		CountyMother,
		ElectoralWardMother,
		-- from booking --
		EDDAgreed,
		EDDMethodAgreed,
		PregnancyFirstContactDate,
		PregnancyFirstContactCareProfessionalType,
		-- Calculate late booking status
		DATEDIFF(week, pred_conception_date, PregnancyFirstContactDate) 
			AS FirstContactGestationWeek,
		CASE 
			WHEN DATEDIFF(
				week, 
				pred_conception_date, 
				PregnancyFirstContactDate) > 12 
			THEN 1
			WHEN DATEDIFF(
				week, 
				pred_conception_date, 
				PregnancyFirstContactDate) <= 12 
			THEN 0
			ELSE NULL
		END AS late_booking,
		LastMenstrualPeriodDate,
		PhysicalDisabilityStatusIndMother,
		FirstLanguageEnglishIndMother,
		EmploymentStatusMother,
		SupportStatusMother,
		EmploymentStatusPartner,
		PreviousCaesareanSections,
		PreviousLiveBirths,
		PreviousStillBirths,
		PreviousLossesLessThan24Weeks,
		SubstanceUseStatus,
		SmokingStatus,
		CigarettesPerDay,
		AlcoholUnitsPerWeek,
		FolicAcidSupplement,
		MHPredictionDetectionIndMother,
		PersonWeight,
		PersonHeight,
		ComplexSocialFactorsInd,
		AgeAtBookingMother,
		LeadAnteProvider,
		CASE 
			WHEN AnE_visits_pre_con IS NULL THEN 0
			ELSE AnE_visits_pre_con
		END AS AnE_visits_pre_con,
		CASE 
			WHEN AnE_visits_early_preg IS NULL THEN 0
			ELSE AnE_visits_early_preg
		END AS AnE_visits_early_preg,
		CASE 
			WHEN AnE_visits_preg IS NULL THEN 0
			ELSE AnE_visits_preg
		END AS AnE_visits_preg
	FROM MSDS_joined
	LEFT JOIN ANE_joined 
		ON MSDS_joined.MSDS_ID_Baby = ANE_joined.MSDS_ID_Baby
)

--DROP TABLE ##MSDSv1
SELECT *
INTO ##MSDSv1
FROM all_joined

SELECT *
FROM ##MSDSv1


