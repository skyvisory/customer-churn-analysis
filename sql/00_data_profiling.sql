-- Exploratory Data Analysis (EDA) at the SQL level

-- ============================================
-- 00_data_profiling.sql
-- Project: Customer Churn Analysis
-- Database: PostgreSQL (churn_analysis)
-- Purpose: Understand data structure, volume, quality and distributions before any business analysis begins
-- Dataset: Telco Customer Churn (Kaggle)
-- ============================================


-- ============================================
-- STEP 1. Row count and raw data sample
-- Business question: How much data do we have and does it look sensible?
-- ============================================
SELECT COUNT(*) as total_rows FROM telco;

-- FINDING: 7,043 customer records
-- INSIGHT: Sufficient volume for statistical analysis and ML modelling. Large enough to segment
--          without losing significance in subgroups.

SELECT * FROM telco LIMIT 10;

-- FINDING: 21 columns covering demographics, services, contract details, payment and churn status
-- INSIGHT: Rich feature set for both SQL exploration and ML feature engineering. Mix of numeric
--          and categorical columns requires different treatment in cleaning step.
-- ============================================


-- ============================================
-- STEP 2. Column names and data types
-- Business question: Are columns the right data types for analysis?
-- ============================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'telco'
ORDER BY ordinal_position;

-- FINDING: Key type issues identified:
--          - totalcharges loaded as VARCHAR not NUMERIC due to blank values in raw data
--          - seniorcitizen loaded as INT (binary 0/1) not text like other yes/no columns
-- INSIGHT: These type mismatches will cause errors in aggregation and ML prep if not handled.
--          totalcharges needs TRIM + NULLIF + ::NUMERIC cast seniorcitizen needs no fix but requires awareness
--          when writing CASE WHEN conditions
-- ACTION:  Handle in cleaning notebook using pandas astype() and fillna() transformations
-- ============================================


-- ============================================
-- STEP 3. NULL value check across key columns
-- Business question: Are there missing values that could skew analysis?
-- ============================================
SELECT
    COUNT(*) as total_rows,
    COUNT(customerid) as customerid_count,
    COUNT(tenure) as tenure_count,
    COUNT(monthlycharges) as monthlycharges_count,
    COUNT(totalcharges) as totalcharges_count,
    COUNT(churn) as churn_count
FROM telco;

-- FINDING: No NULL values found across any key columns.
--          All counts return 7,043 matching total rows.
-- INSIGHT: Clean null profile — no imputation strategy needed for core analytical columns.
--          Blank totalcharges issue is a string problem not a null problem (see Step 7).
-- ============================================


-- ============================================
-- STEP 4. Duplicate customer check
-- Business question: Are there any duplicate records that would inflate counts?
-- ============================================
SELECT
    customerid,
    COUNT(*) as occurrences
FROM telco
GROUP BY customerid
HAVING COUNT(*) > 1;

-- FINDING: Zero duplicate customerIDs found.
--          Every record represents a unique customer.
-- INSIGHT: No deduplication required before analysis.
--          Customer-level aggregations are reliable without additional filtering.
-- ============================================


-- ============================================
-- STEP 5. Numeric column distributions
-- Business question: What are the ranges and averages of key numeric fields?
--                   Any outliers to be aware of?
-- ============================================
SELECT
    ROUND(MIN(tenure), 0) as min_tenure,
    ROUND(MAX(tenure), 0) as max_tenure,
    ROUND(AVG(tenure), 1) as avg_tenure,
    ROUND(MIN(monthlycharges), 2) as min_monthly,
    ROUND(MAX(monthlycharges), 2) as max_monthly,
    ROUND(AVG(monthlycharges), 2) as avg_monthly
FROM telco;

-- FINDING: Tenure ranges 0-72 months, avg 32.4 months
--          Monthly charges range $18.25-$118.75, avg $64.76
-- INSIGHT: Tenure distribution suggests a mix of new and long-standing customers — good for cohort
--          analysis. Monthly charges range is wide enough to segment customers by spend tier meaningfully.
--          No extreme outliers detected in either column.
-- ============================================


-- ============================================
-- STEP 6. Categorical column unique values
-- Business question: What are the valid values in each categorical column?
--                   Any unexpected entries?
-- ============================================
SELECT DISTINCT contract FROM telco;
SELECT DISTINCT internetservice FROM telco;
SELECT DISTINCT paymentmethod FROM telco;
SELECT DISTINCT churn FROM telco;

-- FINDING: Contract: 3 values (Month-to-month, One year, Two year)
--          InternetService: 3 values (DSL, Fiber optic, No)
--          PaymentMethod: 4 values (Electronic check, Mailed check,
--          Bank transfer (automatic), Credit card (automatic))
--          Churn: 2 values (Yes, No) — no nulls or unexpected entries
-- INSIGHT: Clean categorical columns — no typos, no unexpected values, no case inconsistencies detected.
--          All columns ready for GROUP BY analysis and label encoding in ML preparation.
-- ============================================


-- ============================================
-- STEP 7. TotalCharges blank value investigation
-- Business question: Why does TotalCharges have blank values and how should they be treated?
-- ============================================
SELECT
    COUNT(*) as blank_totalcharges
FROM telco
WHERE totalcharges = ' ';

-- Verify these are new customers with zero tenure
SELECT
    customerid,
    tenure,
    monthlycharges,
    totalcharges,
    churn
FROM telco
WHERE totalcharges = ' '
ORDER BY tenure;

-- FINDING: 11 blank TotalCharges values identified.
--          All 11 have tenure = 0 confirming they are brand new customers not yet billed.
--          Underlying value is 0 — blank is a display issue not a data entry error.
--          Note: blanks are single space ' ' not empty string '' — TRIM() required before NULLIF cast
-- INSIGHT: 11 rows = 0.15% of dataset — negligible impact on analysis. No rows need to be dropped.
--          Treatment: TRIM() + NULLIF + ::NUMERIC cast in SQL. pd.to_numeric(errors='coerce') + 
--          fillna(0) in Python cleaning notebook.
-- ACTION:  Document treatment in cleaning notebook.
--          Flag as known data quality issue in README.
-- ============================================


-- ============================================
-- STEP 8. Problematic character check
-- Business question: Are there any non-numeric characters in TotalCharges beyond the known blank issue?
-- ============================================
SELECT
    COUNT(*) as problematic_rows
FROM telco
WHERE totalcharges != ' '
AND totalcharges ~ '[^0-9.]';

-- FINDING: 0 problematic rows found beyond the 11 blanks.
--          No other non-numeric characters present.
-- INSIGHT: TotalCharges is safe to cast to NUMERIC after handling the 11 blank space values with TRIM().
--          No additional cleaning required for this column.
-- ============================================


-- ============================================
-- DATA QUALITY SUMMARY
-- ============================================
-- Overall assessment: HIGH QUALITY dataset
-- 
-- PASSED:
-- ✓ No NULL values in any key column
-- ✓ No duplicate customer records
-- ✓ No unexpected categorical values
-- ✓ No outliers in numeric columns
-- ✓ No problematic characters in TotalCharges
--
-- KNOWN ISSUES (documented and handled):
-- 1. TotalCharges loaded as VARCHAR — cast to NUMERIC
--    using TRIM() + NULLIF + ::NUMERIC in queries
-- 2. TotalCharges has 11 blank space values (0.15%)
--    — all are tenure=0 new customers, treat as 0
-- 3. SeniorCitizen is binary INT (0/1) not text Yes/No
--    — no fix needed but awareness required in CASE WHEN
--
-- READY FOR: Exploratory analysis, feature engineering,
--            and ML model preparation
-- ============================================

/*
============================================
THOUGHT PROCESS
============================================
Before answering any business question, find out:
    Volume — how much data are we working with?
    Shape — what columns exist, what types are they?
    Quality — nulls, duplicates, blanks, weird values?
    Distribution — what's the range of key numbers?
    Categories — what are the possible values in text columns?
*/