-- Exploratory Data Analysis (EDA) at the SQL level

-- Step 1 — How many rows and what does it look like?
-- How many records do we have?
SELECT COUNT(*) as total_rows FROM telco;

-- What does the raw data look like?
SELECT * FROM telco LIMIT 10;

-- Step 2 — What are my columns and data types?
-- See all column names and their data types
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'telco'
ORDER BY ordinal_position;

-- Step 3 — Do I have missing or null values?
-- Check nulls across key columns
SELECT
    COUNT(*) as total_rows,
    COUNT(customerid) as customerid_count,
    COUNT(tenure) as tenure_count,
    COUNT(monthlycharges) as monthlycharges_count,
    COUNT(totalcharges) as totalcharges_count,
    COUNT(churn) as churn_count
FROM telco;

-- Step 4 — Are there duplicates?
-- Check for duplicate customer IDs
SELECT 
    customerid,
    COUNT(*) as occurrences
FROM telco
GROUP BY customerid
HAVING COUNT(*) > 1;

-- Step 5 — Understand numeric columns
-- Distribution of key numeric fields
SELECT
    ROUND(MIN(tenure), 0) as min_tenure,
    ROUND(MAX(tenure), 0) as max_tenure,
    ROUND(AVG(tenure), 1) as avg_tenure,
    ROUND(MIN(monthlycharges), 2) as min_monthly,
    ROUND(MAX(monthlycharges), 2) as max_monthly,
    ROUND(AVG(monthlycharges), 2) as avg_monthly
FROM telco;

-- Step 6 — Understand categorical columns
-- What are the unique values in key categorical columns?
SELECT DISTINCT contract FROM telco;
SELECT DISTINCT internetservice FROM telco;
SELECT DISTINCT paymentmethod FROM telco;
SELECT DISTINCT churn FROM telco;

-- Step 7 — Check for data quality issues
-- TotalCharges was loaded as VARCHAR — check for blanks
SELECT 
    COUNT(*) as blank_totalcharges
FROM telco
WHERE totalcharges = ' ';

/*
Thought process:
Before answering any business question, find out:
    Volume — how much data are we working with?
    Shape — what columns exist, what types are they?
    Quality — nulls, duplicates, blanks, weird values?
    Distribution — what's the range of key numbers?
    Categories — what are the possible values in text columns?
*/