-- Question 1.1
SELECT COUNT(DISTINCT(DESYNPUF_ID))
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	AND BENE_SMI_CVRAGE_TOT_MONS = 12
	
SELECT COUNT(DISTINCT(DESYNPUF_ID))
FROM DE1_0_2009_Beneficiary_Summary_File_Sample_1
WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	AND BENE_SMI_CVRAGE_TOT_MONS = 12

SELECT COUNT(DISTINCT(DESYNPUF_ID))
FROM DE1_0_2010_Beneficiary_Summary_File_Sample_1
WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	AND BENE_SMI_CVRAGE_TOT_MONS = 12

-- Answer
-- 2008 97112
-- 2009 104046
-- 2010 97319

-- Question 1.2
WITH y_2008 AS (
	SELECT DISTINCT(DESYNPUF_ID) AS person_id
	FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
		AND BENE_SMI_CVRAGE_TOT_MONS = 12
),
y_2009 AS (
	SELECT DISTINCT(DESYNPUF_ID) AS person_id
	FROM DE1_0_2009_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
		AND BENE_SMI_CVRAGE_TOT_MONS = 12
), 
y_2010 AS (
	SELECT DISTINCT(DESYNPUF_ID) AS person_id
	FROM DE1_0_2010_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	AND BENE_SMI_CVRAGE_TOT_MONS = 12
)
SELECT COUNT(DISTINCT(p.person_id))
FROM y_2008 p 
INNER JOIN y_2009 q ON p.person_id = q.person_id
INNER JOIN y_2010 r ON r.person_id = p.person_id

-- Answer
-- 86821

-- Question 1.3

WITH y_2008 AS (
	SELECT DISTINCT DESYNPUF_ID AS person_id
	FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	  AND BENE_SMI_CVRAGE_TOT_MONS = 12
),
y_2009 AS (
	SELECT DISTINCT DESYNPUF_ID AS person_id
	FROM DE1_0_2009_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	  AND BENE_SMI_CVRAGE_TOT_MONS = 12
), 
y_2010 AS (
	SELECT DISTINCT DESYNPUF_ID AS person_id
	FROM DE1_0_2010_Beneficiary_Summary_File_Sample_1
	WHERE BENE_HI_CVRAGE_TOT_MONS = 12 
	  AND BENE_SMI_CVRAGE_TOT_MONS = 12
)
SELECT COUNT(DISTINCT p.person_id) AS patient_count
FROM y_2008 p 
INNER JOIN y_2009 q ON p.person_id = q.person_id
INNER JOIN y_2010 r ON r.person_id = p.person_id
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d 
    ON p.person_id = d.DESYNPUF_ID 
WHERE (YEAR(d.CLM_ADMSN_DT) = '2009')
  AND 'V6284' IN (
    d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
    d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
    d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
)

-- Answer
-- 170

-- Question 1.4
WITH multiple_hospitalizations AS (
    SELECT d.DESYNPUF_ID,
           COUNT(*) AS counts
    FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d
    WHERE 'V6284' IN (
        d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
        d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
        d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
    )
    GROUP BY d.DESYNPUF_ID
)

SELECT COUNT(DISTINCT DESYNPUF_ID)
FROM multiple_hospitalizations
WHERE counts > 1;

WITH multiple_hospitalizations AS (
    SELECT d.DESYNPUF_ID,
           COUNT(*) AS counts
    FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d
    WHERE 'V6284' IN (
        d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
        d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
        d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
    )
    GROUP BY d.DESYNPUF_ID
)
SELECT COUNT(DISTINCT m.DESYNPUF_ID),
	CASE WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' ELSE 'Female' END AS sex
FROM multiple_hospitalizations m
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b ON m.DESYNPUF_ID = b.DESYNPUF_ID
WHERE counts > 1
GROUP BY BENE_SEX_IDENT_CD;

WITH multiple_hospitalizations AS (
    SELECT d.DESYNPUF_ID,
           COUNT(*) AS counts
    FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d
    WHERE 'V6284' IN (
        d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
        d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
        d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
    )
    GROUP BY d.DESYNPUF_ID
)
SELECT AVG(TIMESTAMPDIFF(YEAR, b.BENE_BIRTH_DT, DATE('2008-12-31'))) AS avg_age,
       CASE 
           WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' 
           ELSE 'Female' 
       END AS sex
FROM multiple_hospitalizations m
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b ON m.DESYNPUF_ID = b.DESYNPUF_ID
WHERE counts > 1
GROUP BY b.BENE_SEX_IDENT_CD;

WITH multiple_hospitalizations AS (
    SELECT d.DESYNPUF_ID,
           COUNT(*) AS counts
    FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d
    WHERE 'V6284' IN (
        d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
        d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
        d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
    )
    GROUP BY d.DESYNPUF_ID
)
SELECT CASE 
           WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' 
           ELSE 'Female' 
       END AS sex,
       AVG(i.CLM_THRU_DT - i.CLM_FROM_DT)
FROM multiple_hospitalizations m
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b ON m.DESYNPUF_ID = b.DESYNPUF_ID
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i ON i.DESYNPUF_ID = b.DESYNPUF_ID
GROUP BY b.BENE_SEX_IDENT_CD;

-- Answer
-- Multiple Hospitalizations 8
-- Male Count 5
-- Female Count 3
-- Male Age 69.0000
-- Female Age 71.6667
-- Male LOS 146.73123909249563
-- Female LOS 199.85802469135803
-- There were 8 patients in 2009 that had multiple hospitalizations. There were 5 men with multiple hospitalizations vs 3 women with multiple hospitalizatiosn. Men tend to be younger, on average, compared to women. Interestingly, the average length of stay is much higher for women compared to men.

-- Question 2.1

CREATE TEMPORARY TABLE cohort AS
SELECT d.DESYNPUF_ID, 
		d.CLM_ADMSN_DT AS ideation_date
FROM DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 d
WHERE 'V6284' IN (
    d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
    d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
    d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
);

WITH visits AS (SELECT c.DESYNPUF_ID,
       COUNT(*) AS visits
FROM cohort c
INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o 
    ON o.DESYNPUF_ID = c.DESYNPUF_ID
WHERE DATEDIFF(o.CLM_FROM_DT, c.ideation_date) < 365 
  AND 'V6284' NOT IN (
      o.ADMTNG_ICD9_DGNS_CD, o.ICD9_DGNS_CD_1, o.ICD9_DGNS_CD_2, o.ICD9_DGNS_CD_3,
      o.ICD9_DGNS_CD_4, o.ICD9_DGNS_CD_5, o.ICD9_DGNS_CD_6, o.ICD9_DGNS_CD_7,
      o.ICD9_DGNS_CD_8, o.ICD9_DGNS_CD_9, o.ICD9_DGNS_CD_10
  )
GROUP BY c.DESYNPUF_ID)
SELECT avg(visits) AS average,
		STD(visits) AS standard_deviation
FROM visits 

-- Answer
-- Average: 13.6421	
-- Standard Deviation: 8.52042775122709

-- Question 2.2

WITH visits AS (
    SELECT c.DESYNPUF_ID,
           COUNT(*) AS visits
    FROM cohort c
    INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o 
        ON o.DESYNPUF_ID = c.DESYNPUF_ID
    WHERE DATEDIFF(c.ideation_date, o.CLM_ADMSN_DT) BETWEEN 0 AND 364
      AND (
          o.ADMTNG_ICD9_DGNS_CD BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_1 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_2 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_3 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_4 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_5 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_6 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_7 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_8 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_9 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_10 BETWEEN '290' AND '319'
      )
    GROUP BY c.DESYNPUF_ID
)
SELECT AVG(visits) AS average,
       STDDEV(visits) AS standard_deviation
FROM visits;

-- Answer
-- Average: 1.7801	
-- Standard Deivation: 1.2942436581057506

-- Question 2.3

WITH visits AS (
    SELECT c.DESYNPUF_ID,
           COUNT(*) AS visits
    FROM cohort c
    INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o 
        ON o.DESYNPUF_ID = c.DESYNPUF_ID
    WHERE DATEDIFF(o.CLM_FROM_DT, c.ideation_date) < 365 
      AND 'V6284' NOT IN (
      o.ADMTNG_ICD9_DGNS_CD, o.ICD9_DGNS_CD_1, o.ICD9_DGNS_CD_2, o.ICD9_DGNS_CD_3,
      o.ICD9_DGNS_CD_4, o.ICD9_DGNS_CD_5, o.ICD9_DGNS_CD_6, o.ICD9_DGNS_CD_7,
      o.ICD9_DGNS_CD_8, o.ICD9_DGNS_CD_9, o.ICD9_DGNS_CD_10
  )    GROUP BY c.DESYNPUF_ID
)
SELECT CASE WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' ELSE 'Female' END AS sex,
       AVG(v.visits) AS average,
       STDDEV(v.visits) AS standard_deviation
FROM visits v
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b 
    ON b.DESYNPUF_ID = v.DESYNPUF_ID
GROUP BY b.BENE_SEX_IDENT_CD;


WITH visits AS (
    SELECT c.DESYNPUF_ID,
           COUNT(*) AS visits
    FROM cohort c
    INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o 
        ON o.DESYNPUF_ID = c.DESYNPUF_ID
    WHERE DATEDIFF(c.ideation_date, o.CLM_ADMSN_DT) BETWEEN 0 AND 364
      AND (
          o.ADMTNG_ICD9_DGNS_CD BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_1 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_2 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_3 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_4 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_5 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_6 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_7 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_8 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_9 BETWEEN '290' AND '319' OR
          o.ICD9_DGNS_CD_10 BETWEEN '290' AND '319'
      )
    GROUP BY c.DESYNPUF_ID
)
SELECT CASE WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' ELSE 'Female' END AS sex,
       AVG(v.visits) AS average,
       STDDEV(v.visits) AS standard_deviation
FROM visits v
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b 
    ON b.DESYNPUF_ID = v.DESYNPUF_ID
GROUP BY b.BENE_SEX_IDENT_CD;

-- Answer
-- Female:	Average: 13.4385	Standard Deviation: 8.435360631766775
-- Male:	Average: 13.9821	Standard Deviation: 8.649919635110924
-- Female:	Average: 1.8057	Standard Deviation: 1.281504218184431
-- Male:	Average: 1.7383	Standard Deviation: 1.3137408142658378
-- Males tend to have slightly more all cause outpatient visits compared to females on average. The number of mental health visits is slightly more for females than males on average.

-- Question 3.1

CREATE TEMPORARY TABLE inpatient_cohort AS
SELECT d.DESYNPUF_ID, 
		d.CLM_ID,
		d.CLM_THRU_DT AS discharge_date
FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 d
WHERE 'V6284' IN (
    d.ADMTNG_ICD9_DGNS_CD, d.ICD9_DGNS_CD_1, d.ICD9_DGNS_CD_2, d.ICD9_DGNS_CD_3,
    d.ICD9_DGNS_CD_4, d.ICD9_DGNS_CD_5, d.ICD9_DGNS_CD_6, d.ICD9_DGNS_CD_7,
    d.ICD9_DGNS_CD_8, d.ICD9_DGNS_CD_9, d.ICD9_DGNS_CD_10
);
SELECT COUNT(DISTINCT(i.DESYNPUF_ID))
FROM inpatient_cohort i
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 ic ON ic.DESYNPUF_ID = i.DESYNPUF_ID
WHERE ic.CLM_ADMSN_DT - i.discharge_date <= 30 
	AND i.CLM_ID != ic.CLM_ID 

-- Answer
-- 267

-- Question 3.2
SELECT COUNT(DISTINCT(i.DESYNPUF_ID))
FROM inpatient_cohort i
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 ic ON ic.DESYNPUF_ID = i.DESYNPUF_ID
INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o ON o.DESYNPUF_ID = ic.DESYNPUF_ID 
WHERE (ic.CLM_ADMSN_DT - i.discharge_date <= 30 
	AND i.CLM_ID != ic.CLM_ID) OR
	(o.CLM_FROM_DT - i.discharge_date <= 30)

-- Answer
-- 413

-- Question 3.3
SELECT COUNT(DISTINCT(i.DESYNPUF_ID))
FROM inpatient_cohort i
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 ic ON ic.DESYNPUF_ID = i.DESYNPUF_ID
INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o ON o.DESYNPUF_ID = ic.DESYNPUF_ID 
WHERE (
    (ic.CLM_ADMSN_DT - i.discharge_date <= 30 
    AND i.CLM_ID != ic.CLM_ID
    AND (
        ic.ADMTNG_ICD9_DGNS_CD BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_1 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_2 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_3 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_4 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_5 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_6 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_7 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_8 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_9 BETWEEN '290' AND '319' OR
        ic.ICD9_DGNS_CD_10 BETWEEN '290' AND '319'
    ))
) 
OR 
(
    o.CLM_FROM_DT - i.discharge_date <= 30 
    AND (
        o.ADMTNG_ICD9_DGNS_CD BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_1 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_2 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_3 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_4 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_5 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_6 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_7 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_8 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_9 BETWEEN '290' AND '319' OR
        o.ICD9_DGNS_CD_10 BETWEEN '290' AND '319'
    )
)

-- Answer
-- 258

-- Question 3.4
SELECT CASE WHEN b.BENE_SEX_IDENT_CD = 1 THEN 'Male' ELSE 'Female' END AS sex,
	COUNT(DISTINCT(i.DESYNPUF_ID))
FROM inpatient_cohort i
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 ic ON ic.DESYNPUF_ID = i.DESYNPUF_ID
INNER JOIN DE1_0_2008_to_2010_Outpatient_Claims_Sample_1 o ON o.DESYNPUF_ID = ic.DESYNPUF_ID 
INNER JOIN DE1_0_2008_Beneficiary_Summary_File_Sample_1 b ON b.DESYNPUF_ID = i.DESYNPUF_ID
WHERE (ic.CLM_ADMSN_DT - i.discharge_date <= 30 
	AND i.CLM_ID != ic.CLM_ID) OR
	(o.CLM_FROM_DT - i.discharge_date <= 30)
GROUP BY b.BENE_SEX_IDENT_CD;

-- Answer
-- Male	163
-- Female	250