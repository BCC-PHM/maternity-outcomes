WITH 
allLiveBirths AS 
(
	SELECT 
		ElectoralWardMother, 
		COUNT(*) AS all_births
	FROM ##MSDSv1
	WHERE 
		BirthWeight IS NOT NULL AND
		GestationLengthBirth IS NOT NULL AND
		PostcodeDistrictMother LIKE 'B%'
	GROUP BY ElectoralWardMother
),
premature AS (
	SELECT 
		ElectoralWardMother, 
		COUNT(*) AS premature
	FROM ##MSDSv1
	WHERE 
		BirthWeight IS NOT NULL AND
		GestationLengthBirth IS NOT NULL AND
		GestationLengthBirth < 37*7 AND
		PostcodeDistrictMother LIKE 'B%'
	GROUP BY ElectoralWardMother
),
term_LBW AS (
	SELECT 
		ElectoralWardMother, 
		COUNT(*) AS term_LBW
	FROM ##MSDSv1
	WHERE 
		BirthWeight IS NOT NULL AND
		GestationLengthBirth IS NOT NULL AND
		GestationLengthBirth >= 37*7 AND
		BirthWeight < 2500 AND
		PostcodeDistrictMother LIKE 'B%'
	GROUP BY ElectoralWardMother
), 
joined_by_ward AS
(
	SELECT 
		allb.ElectoralWardMother,
		allb.all_births,
		premature,
		term_LBW
	FROM allLiveBirths AS allb
	FULL JOIN premature 
		on allb.ElectoralWardMother = premature.ElectoralWardMother
	FULL JOIN term_LBW 
		on allb.ElectoralWardMother = term_LBW.ElectoralWardMother
), 
suppressed AS 
(
	SELECT 
		ElectoralWardMother,
		all_births,
		CASE 
			WHEN premature < 5 THEN -1
			WHEN premature IS NULL THEN 0
			ELSE premature
		END AS premature,
		CASE 
			WHEN term_LBW < 5 THEN -1
			WHEN term_LBW IS NULL THEN 0
			ELSE term_LBW
		END AS term_LBW
	FROM joined_by_ward
)

SELECT *
FROM suppressed
WHERE ElectoralWardMother IS NOT NULL