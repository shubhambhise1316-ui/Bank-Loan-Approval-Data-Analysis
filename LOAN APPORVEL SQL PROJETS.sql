CREATE TABLE APPROVED_LOANS (
	APPLICANT_ID INTEGER PRIMARY KEY,
	AGE INTEGER,
	GENDER VARCHAR(100),
	MARITAL_STATUS VARCHAR(100),
	ANNUAL_INCOME INTEGER,
	LOAN_AMOUNT INTEGER,
	CREDIT_SCORE INTEGER,
	EXISTING_LOANS_COUNT INTEGER,
	EMPLOYMENT_STATUS VARCHAR(100),
	LOAN_APPROVED INTEGER
);

DROP TABLE APPROVED_LOANS;

SELECT
	*
FROM
	APPROVED_LOANS;

--Query A: Overall KPI Portfolio Summary
SELECT
	COUNT(APPLICANT_ID) AS TOTAL_APPLICANTS,
	ROUND(AVG(ANNUAL_INCOME), 2) AS AVG_ANNUAL_INCOME,
	ROUND(AVG(LOAN_AMOUNT), 2) AS AVG_LOAN_AMOUNT,
	ROUND(AVG(CREDIT_SCORE), 2) AS AVG_CREDIT_SCORE,
	ROUND(
		SUM(LOAN_APPROVED) * 100.0 / COUNT(APPLICANT_ID),
		2
	) AS OVERALL_APPROVAL_RATE_PCT
FROM
	PUBLIC.APPROVED_LOANS;

--Query B: Demographics Breakdown (Gender & Marital Status)
SELECT 
    gender,
    marital_status,
    COUNT(applicant_id) AS total_applicants,
    SUM(loan_approved) AS approved_count,
    ROUND(SUM(loan_approved) * 100.0 / COUNT(applicant_id), 2) AS approval_rate_pct
FROM public.approved_loans
GROUP BY gender, marital_status
ORDER BY total_applicants DESC;

 ---Credit Score Risk Tiering
 SELECT 
    CASE 
        WHEN credit_score >= 800 THEN 'Excellent (800+)'
        WHEN credit_score >= 700 THEN 'Good (700-799)'
        WHEN credit_score >= 600 THEN 'Fair (600-699)'
        ELSE 'Poor (<600)'
    END AS credit_tier,
    COUNT(applicant_id) AS total_applicants,
    SUM(loan_approved) AS approved_count,
    ROUND(SUM(loan_approved) * 100.0 / COUNT(applicant_id), 2) AS approval_rate_pct
FROM public.approved_loans
GROUP BY 1
ORDER BY MIN(credit_score) DESC;

 --- Debt-to-Income (DTI) Operational Ratio Proxy
 	SELECT 
    CASE WHEN loan_approved = 1 THEN 'Approved' ELSE 'Rejected' END AS loan_status,
    COUNT(applicant_id) AS total_cases,
    ROUND(AVG(loan_amount * 1.0 / NULLIF(annual_income, 0)), 4) AS avg_loan_to_income_ratio,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM public.approved_loans
GROUP BY loan_approved;

---Risk Scoring Classifier Profile
SELECT 
    applicant_id,
    annual_income,
    loan_amount,
    credit_score,
    employment_status,
    CASE 
        WHEN credit_score < 500 OR employment_status = 'Unemployed' THEN 'High Risk'
        WHEN credit_score BETWEEN 500 AND 699 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_profile,
    CASE WHEN loan_approved = 1 THEN 'Approved' ELSE 'Rejected' END AS actual_outcome
FROM public.approved_loans
LIMIT 20;

