-- ============================================
-- Project: Customer Churn Analysis
-- File: 01_exploration.sql
-- Database: PostgreSQL (churn_analysis)
-- Purpose: Explore churn patterns across key
--          customer segments
-- Dataset: Telco Customer Churn (Kaggle)
-- ============================================

-- ============================================
-- 1. Overall churn rate
-- Business question: How significant is our churn problem overall?
-- Hypothesis: Telecom industry average churn sits between 15-25% annually. Anything above signals urgency.
-- ============================================
SELECT
    churn,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM telco
GROUP BY churn;

-- FINDING: 26.5% of customers churned — above the 15-25% telecom industry benchmark
-- INSIGHT: This is not a minor retention issue. Over 1 in 4 customers leaving signals 
--          a structural problem worth investigating across segments, not just surface fixes
-- ACTION:  Prioritise identifying which segments drive this above-average churn rate
--          before recommending any interventions
-- ============================================

-- ============================================
-- 2. Churn rate by contract type
-- Business question: Does contract length affect likelihood of churn?
-- Hypothesis: Shorter contracts = easier to leave = higher churn rate
-- ============================================
SELECT
    contract,
    COUNT(*) as total_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) as churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY contract
ORDER BY churn_rate DESC;

-- FINDING: Month-to-month customers churn at 42% vs 3% for two-year contracts — a 15x difference
-- INSIGHT: Contract type is the strongest predictor of churn. Retention strategy: incentivize longer 
--          commitments early in the customer journey
-- ACTION:  Offer discount to move month-to-month customers to annual contracts within first 60 days
-- ============================================

-- 3. Churn rate by tenure group
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '48+ months'
    END as tenure_group,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY tenure_group
ORDER BY churn_rate DESC;


-- 4. Churn rate by internet service type
SELECT
    internetservice,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY internetservice
ORDER BY churn_rate DESC;


-- 5. Churn rate by payment method
SELECT
    paymentmethod,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY paymentmethod
ORDER BY churn_rate DESC;


-- 6. Average monthly charges — churned vs retained
SELECT
    churn,
    ROUND(AVG(monthlycharges), 2) as avg_monthly_charges,
    ROUND(AVG(tenure), 1) as avg_tenure_months,
    ROUND(AVG(NULLIF(totalcharges, '')::NUMERIC), 2) as avg_total_charges
FROM telco
GROUP BY churn;


-- 7. Highest risk segment
SELECT
    contract,
    internetservice,
    paymentmethod,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY contract, internetservice, paymentmethod
HAVING COUNT(*) > 50
ORDER BY churn_rate DESC
LIMIT 10;


-- 8. Senior citizen churn comparison
SELECT
    seniorcitizen,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY seniorcitizen;


-- 9. Churn rate by number of services subscribed
SELECT
    (CASE WHEN phoneservice = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN internetservice != 'No' THEN 1 ELSE 0 END +
     CASE WHEN onlinesecurity = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN onlinebackup = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN deviceprotection = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN techsupport = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN streamingtv = 'Yes' THEN 1 ELSE 0 END +
     CASE WHEN streamingmovies = 'Yes' THEN 1 ELSE 0 END) as services_count,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY services_count
ORDER BY services_count;


-- 10. Revenue at risk from churned customers
SELECT
    contract,
    ROUND(SUM(monthlycharges), 2) as monthly_revenue_lost,
    ROUND(SUM(monthlycharges) * 12, 2) as annual_revenue_at_risk,
    COUNT(*) as churned_customers
FROM telco
WHERE churn = 'Yes'
GROUP BY contract
ORDER BY annual_revenue_at_risk DESC;
```

---

Save and commit:
```
update SQL to PostgreSQL syntax + add revenue at risk query