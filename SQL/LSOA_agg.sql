WITH 

allBirths AS 
(
	SELECT 
		LSOAMother2011,
		COUNT(*) AS allbirths
	FROM ##MSDSv1
	GROUP BY LSOAMother2011
),

normalbw AS
(
    SELECT 
		LSOAMother2011,
		COUNT(BirthWeight) AS NormalBW
	FROM ##MSDSv1
	WHERE BirthWeight >= 2500
	GROUP BY LSOAMother2011
),
lowbw AS(
	SELECT LSOAMother2011,
          COUNT(BirthWeight) AS LowBW
	FROM ##MSDSv1
	WHERE BirthWeight < 2500 AND GestationLengthBirth >= 259
	GROUP BY LSOAMother2011
),
PrematureLive AS
(
    SELECT 
		LSOAMother2011,
		COUNT(GestationLengthBirth) AS PrematureLive
	FROM ##MSDSv1
	WHERE GestationLengthBirth >= 168 AND GestationLengthBirth <= 252
	GROUP BY LSOAMother2011
)

SELECT 
	    allBirths.LSOAMother2011,
		allbirths,
		NormalBW,
		LowBW,
		PrematureLive
from allBirths
LEFT JOIN normalbw
	on allBirths.LSOAMother2011 = normalbw.LSOAMother2011
LEFT JOIN lowbw
	on allBirths.LSOAMother2011 = lowbw.LSOAMother2011
LEFT JOIN PrematureLive
	on allBirths.LSOAMother2011 = PrematureLive.LSOAMother2011
WHERE allBirths.LSOAMother2011 IS NOT NULL
order by allbirths DESC