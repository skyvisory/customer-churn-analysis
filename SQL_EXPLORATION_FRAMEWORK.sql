-- ============================================
-- SQL_EXPLORATION_FRAMEWORK.sql
-- Purpose: A reusable reference framework for approaching any new dataset in SQL.
--          Copy this file into any new project and adapt table/column names as needed.
--          Built from the Telco Churn Analysis project.
-- ============================================


-- ============================================
-- PHASE 1: UNDERSTAND THE DATA
-- Before writing any business queries, understand what you're working with. Never skip this phase.
-- ============================================

-- 1.1 How much data do we have?
SELECT COUNT(*) as total_rows FROM your_table;

-- 1.2 What does the raw data look like?
SELECT * FROM your_table LIMIT 10;

-- 1.3 What columns and data types exist?
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'your_table'
ORDER BY ordinal_position;

-- 1.4 What are the numeric column ranges?
-- Replace with your actual numeric columns
SELECT
    MIN(numeric_col_1) as min_1,
    MAX(numeric_col_1) as max_1,
    ROUND(AVG(numeric_col_1), 2) as avg_1,
    MIN(numeric_col_2) as min_2,
    MAX(numeric_col_2) as max_2,
    ROUND(AVG(numeric_col_2), 2) as avg_2
FROM your_table;

-- 1.5 What are the unique values in categorical columns?
-- Run once per categorical column
SELECT DISTINCT categorical_col1 FROM your_table;
SELECT DISTINCT categorical_col2 FROM your_table;

-- WHY THIS MATTERS:
-- Knowing your data types prevents casting errors.
-- Knowing ranges reveals outliers before they corrupt analysis.
-- Knowing categorical values catches typos and case issues.
-- ============================================


-- ============================================
-- PHASE 2: DATA QUALITY CHECKS
-- Trust nothing until you verify it.
-- Document every issue found and how you handled it.
-- ============================================

-- 2.1 Check for NULL values across key columns
SELECT
    COUNT(*) as total_rows,
    COUNT(col_1) as col_1_count,
    COUNT(col_2) as col_2_count,
    COUNT(col_3) as col_3_count,
    COUNT(target_col) as target_count
FROM your_table;
-- Any count less than total_rows = NULLs present

-- 2.2 Check for duplicates on your primary key
SELECT
    primary_key_col,
    COUNT(*) as occurrences
FROM your_table
GROUP BY primary_key_col
HAVING COUNT(*) > 1;
-- Zero rows returned = no duplicates

-- 2.3 Check for blank string values
-- Important: blanks are not NULLs — COUNT() misses them
SELECT
    COUNT(*) as blank_count
FROM your_table
WHERE TRIM(col_name) = '';

-- 2.4 Check for unexpected characters in numeric columns
-- stored as text
SELECT
    COUNT(*) as problematic_rows
FROM your_table
WHERE col_name != ' '
AND col_name ~ '[^0-9.]';

-- 2.5 Check for outliers in numeric columns
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP
        (ORDER BY numeric_col) as q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY numeric_col) as median,
    PERCENTILE_CONT(0.75) WITHIN GROUP
        (ORDER BY numeric_col) as q3,
    PERCENTILE_CONT(0.99) WITHIN GROUP
        (ORDER BY numeric_col) as p99,
    MAX(numeric_col) as max_value
FROM your_table;
-- Large gap between p99 and max = potential outliers

-- DATA QUALITY DECISION FRAMEWORK:
-- NULL values    → impute (mean/median/mode) or drop
-- Duplicates     → deduplicate on primary key
-- Blank strings  → TRIM() + NULLIF() before casting
-- Wrong types    → cast with ::NUMERIC, ::DATE etc
-- Outliers       → investigate before removing —
--                  outliers are sometimes the insight
-- ============================================


-- ============================================
-- PHASE 3: UNDERSTAND YOUR TARGET VARIABLE
-- Always start with the thing you're trying to explain — the outcome, metric, or KPI.
-- Get the baseline before segmenting anything.
-- ============================================

-- 3.1 Distribution of target variable
-- For binary targets (churn, conversion, default)
SELECT
    target_col,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM your_table
GROUP BY target_col;

-- 3.2 For numeric targets (revenue, score, days)
SELECT
    ROUND(AVG(target_col), 2) as mean,
    PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY target_col) as median,
    ROUND(STDDEV(target_col), 2) as std_dev,
    MIN(target_col) as min_val,
    MAX(target_col) as max_val
FROM your_table;

-- WHY THIS MATTERS:
-- Baseline tells you if you have a class imbalance problem (e.g. 1% churn vs 99% not churned).
-- Heavily imbalanced targets need special ML treatment.
-- Always benchmark against industry standard if available.
-- ============================================


-- ============================================
-- PHASE 4: SEGMENT YOUR TARGET VARIABLE
-- Now break the target down by every meaningful dimension. This is where insights live.
-- Use a consistent pattern for every segment.
-- ============================================

-- 4.1 The universal segmentation pattern
-- Copy and adapt for every categorical column
SELECT
    segment_col,
    COUNT(*) as total,
    SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) as target_count,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
GROUP BY segment_col
ORDER BY target_rate DESC;

-- 4.2 Bin continuous variables before segmenting
-- Binning turns raw numbers into meaningful groups
SELECT
    CASE
        WHEN numeric_col <= 25 THEN 'Band 1'
        WHEN numeric_col <= 50 THEN 'Band 2'
        WHEN numeric_col <= 75 THEN 'Band 3'
        ELSE 'Band 4'
    END as band,
    COUNT(*) as total,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
GROUP BY band
ORDER BY target_rate DESC;

-- 4.3 Financial impact per segment
-- Always attach a dollar figure to churn/conversion rates
SELECT
    segment_col,
    COUNT(*) as affected_customers,
    ROUND(SUM(revenue_col), 2) as monthly_impact,
    ROUND(SUM(revenue_col) * 12, 2) as annual_impact
FROM your_table
WHERE target_col = 'Yes'
GROUP BY segment_col
ORDER BY annual_impact DESC;

-- SEGMENTATION PRINCIPLES:
-- Always order by target_rate DESC — most urgent first
-- Always include total count — rates without volume mislead
-- Always attach revenue — percentages need dollar context
-- Always ask: is this segment large enough to act on?
-- ============================================


-- ============================================
-- PHASE 5: FIND THE HIGHEST RISK COMBINATION
-- Single dimensions tell part of the story.
-- Combining dimensions reveals the full risk profile.
-- ============================================

-- 5.1 Two-dimensional risk matrix
SELECT
    dim_1,
    dim_2,
    COUNT(*) as total,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
GROUP BY dim_1, dim_2
HAVING COUNT(*) > 50
ORDER BY target_rate DESC
LIMIT 10;

-- 5.2 Three-dimensional risk matrix
-- Add a third dimension carefully — too many dimensions fragments your segments
SELECT
    dim_1,
    dim_2,
    dim_3,
    COUNT(*) as total,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
GROUP BY dim_1, dim_2, dim_3
HAVING COUNT(*) > 50
ORDER BY target_rate DESC
LIMIT 10;

-- DIMENSION SELECTION PRINCIPLES:
-- Use HAVING COUNT(*) > 50 to filter small segments
-- Start with the 2-3 strongest single drivers
-- Add dimensions only if they add new information
-- Avoid tenure/continuous vars in convergence queries — bin them first or they fragment results too much
-- Goal: find a segment large enough to act on
-- ============================================


-- ============================================
-- PHASE 6: INVESTIGATE ANOMALIES
-- When results don't match expectations — dig in.
-- Anomalies are either data quality issues or the most interesting findings in your analysis.
-- ============================================

-- 6.1 Drill into an anomalous segment
SELECT
    *
FROM your_table
WHERE anomalous_col = 'unexpected_value'
LIMIT 20;

-- 6.2 Simpson's Paradox check
-- When an aggregate trend reverses within subgroups compare subgroup compositions to find the culprit
SELECT
    subgroup_col,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2) as pct_of_total,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
WHERE anomalous_segment_filter
GROUP BY subgroup_col
ORDER BY total DESC;

-- 6.3 Confounding variable test
-- When two variables correlate with target — test if one explains the other
-- Method: check target rate within identical levels of the control variable
SELECT
    control_var,
    test_var,
    COUNT(*) as total,
    ROUND(SUM(CASE WHEN target_col = 'Yes'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) as target_rate
FROM your_table
GROUP BY control_var, test_var
ORDER BY control_var, target_rate DESC;

-- ANOMALY INVESTIGATION PRINCIPLES:
-- Never discard an anomaly without understanding it
-- Simpson's Paradox: aggregate trend ≠ subgroup trend
-- Confounding: variable A explains variable B's effect
-- Document every anomaly — even if resolved
-- Unresolved anomalies go in README as limitations
-- ============================================


-- ============================================
-- PHASE 7: WINDOW FUNCTIONS REFERENCE
-- Essential patterns for business analysis
-- ============================================

-- 7.1 Percentage of total (whole table)
ROUND(COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER(), 2) as pct_of_total

-- 7.2 Percentage within a group (partition)
ROUND(COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER(PARTITION BY group_col), 2)
    as pct_within_group

-- 7.3 Running total
SUM(revenue_col) OVER(
    ORDER BY date_col
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    as running_total

-- 7.4 Rank within a group
RANK() OVER(
    PARTITION BY group_col
    ORDER BY metric_col DESC)
    as rank_within_group

-- 7.5 Period over period comparison
LAG(metric_col, 1) OVER(
    PARTITION BY group_col
    ORDER BY date_col)
    as previous_period_value

-- WINDOW FUNCTION PRINCIPLES:
-- OVER() = across entire result set
-- OVER(PARTITION BY x) = within each group of x
-- OVER(ORDER BY x) = running calculation
-- Window functions never reduce row count unlike GROUP BY which collapses rows
-- ============================================


-- ============================================
-- PHASE 8: COMMON DATA TYPE FIXES
-- Copy these patterns whenever you hit type errors
-- ============================================

-- 8.1 Cast VARCHAR to NUMERIC safely
-- Handles blanks and spaces without errors
NULLIF(TRIM(col_name), '')::NUMERIC

-- 8.2 Cast VARCHAR to DATE
col_name::DATE
-- or for specific formats:
TO_DATE(col_name, 'YYYY-MM-DD')

-- 8.3 Cast INT to FLOAT for division
-- Prevents integer division returning whole numbers
col_name::FLOAT / other_col

-- 8.4 Handle division by zero
CASE WHEN denominator = 0
    THEN NULL
    ELSE ROUND(numerator * 100.0 / denominator, 2)
END as safe_percentage

-- 8.5 Standardise text case for grouping
LOWER(TRIM(col_name)) as standardised_col
-- Prevents 'Yes' and 'yes' and ' yes' grouping separately
-- ============================================


-- ============================================
-- PHASE 9: THE BUSINESS CONTEXT TEMPLATE
-- Use this structure for every query you write.
-- Analysis without context is just computation.
-- ============================================

/*
-- ============================================
-- [Query number and name]
-- Business question: [The question in plain English]
-- Hypothesis: [What you expect to find and why]
-- Note: [Any technical decisions worth explaining]
-- ============================================
[YOUR SQL QUERY HERE]

-- FINDING: [What the data actually showed]
-- INSIGHT: [What it means for the business]
-- ACTION:  [What should be done about it]
-- ============================================
*/

-- THE GOLDEN RULE:
-- Every query should answer a business question.
-- If you can't state the business question —
-- you shouldn't be writing the query yet.
-- ============================================


-- ============================================
-- QUICK REFERENCE: WHEN TO USE WHAT
-- ============================================

-- WHERE vs HAVING:
-- WHERE  → filters rows BEFORE grouping
-- HAVING → filters groups AFTER grouping
-- Use HAVING for conditions on aggregates (COUNT, SUM)

-- GROUP BY vs WINDOW FUNCTIONS:
-- GROUP BY    → collapses rows, one row per group
-- WINDOW OVER → keeps all rows, adds calculation alongside

-- COUNT(*) vs COUNT(col):
-- COUNT(*)    → counts all rows including NULLs
-- COUNT(col)  → counts only non-NULL values in col
-- Use difference to detect NULLs

-- SUM(CASE WHEN) vs COUNT(CASE WHEN):
-- Both work for conditional counting
-- SUM(CASE WHEN x THEN 1 ELSE 0 END) = standard pattern
-- COUNT(CASE WHEN x THEN 1 END) = alternative, same result

-- JOIN types:
-- INNER JOIN → only matching rows in both tables
-- LEFT JOIN  → all rows from left, matched from right
-- Use LEFT JOIN when right side may have no match

-- TRIM() vs NULLIF():
-- TRIM()  → removes leading/trailing whitespace
-- NULLIF() → converts specific value to NULL
-- Use together: NULLIF(TRIM(col), '') for blank handling
-- ============================================


-- ============================================
-- REFERENCE: EXAMPLES OF GOOD BUSINESS QUESTIONS
-- Use these as inspiration when approaching any new dataset. Good questions come before good SQL.
-- Organised by business domain.
-- ============================================


-- CUSTOMER RETENTION & CHURN
-- · What percentage of customers are we losing monthly?
-- · Which customer segment has the highest churn rate?
-- · When in the customer lifecycle do most customers leave?
-- · What is the dollar value of customers lost this quarter?
-- · Which product or service type drives the most churn?
-- · How does churn rate differ between contract lengths?
-- · What does our highest risk customer profile look like?
-- · How much revenue could we recover with a 10% churn reduction?
-- · Are churned customers concentrated in specific geographies?
-- · Do customers who use more products churn less?


-- REVENUE & GROWTH
-- · What is our month over month revenue growth rate?
-- · Which product line generates the most revenue?
-- · What is the average revenue per customer by segment?
-- · Which customers account for 80% of our revenue?
-- · How does revenue per customer change over their lifetime?
-- · What percentage of revenue comes from new vs existing customers?
-- · Which sales rep or channel generates the highest LTV customers?
-- · Where are we leaving money on the table — low spend, high engagement?
-- · What is our revenue concentration risk — how dependent on top 10 customers?
-- · How does seasonal variation affect our revenue by product line?


-- SALES & PIPELINE (RevOps)
-- · What is our overall win rate by deal stage?
-- · Where in the pipeline are we losing the most deals?
-- · What is the average sales cycle length by deal size?
-- · Which lead source produces the highest quality opportunities?
-- · How accurate are our quarterly forecasts vs actual closed revenue?
-- · What is our pipeline coverage ratio — do we have enough to hit target?
-- · Which reps are consistently over or underperforming and why?
-- · How does deal size affect win rate and sales cycle?
-- · What is the conversion rate from MQL to SQL to closed won?
-- · Are there seasonal patterns in pipeline creation or close rates?


-- CUSTOMER BEHAVIOUR & ENGAGEMENT
-- · How frequently do customers use our product or service?
-- · What actions do customers take before they churn?
-- · Which features or services are most correlated with retention?
-- · How long does it take a new customer to reach first value moment?
-- · What does a high engagement customer look like vs low engagement?
-- · Which customer cohorts have the strongest retention curves?
-- · Do customers who onboard faster have better long term retention?
-- · What is the relationship between support ticket volume and churn?
-- · How does product usage change in the 30 days before cancellation?
-- · Which customer segments are growing vs shrinking over time?


-- FINANCIAL & UNIT ECONOMICS
-- · What is our customer acquisition cost by channel?
-- · What is the average customer lifetime value by segment?
-- · What is our LTV to CAC ratio — are we acquiring profitably?
-- · How long does it take to recover the cost of acquiring a customer?
-- · What is our net revenue retention — are existing customers growing?
-- · How does gross margin vary by product, segment, or geography?
-- · Which customer segments are profitable vs loss-making?
-- · What would a 5% price increase do to revenue and churn?
-- · How does our unit economics compare across different cohorts?
-- · What is the revenue impact of our top 10 customer relationships?


-- OPERATIONS & EFFICIENCY
-- · Where are the bottlenecks in our fulfilment or service process?
-- · Which team or region is most efficient by output per headcount?
-- · What is our average response or resolution time by issue type?
-- · How does operational efficiency correlate with customer satisfaction?
-- · Which processes have the highest error or rework rate?
-- · Where are we over or under-resourced relative to demand?
-- · What is the cost per transaction or service delivery by channel?
-- · How does capacity utilisation vary by time period or location?
-- · Which operational metrics are leading indicators of customer outcomes?
-- · Where do delays or failures most commonly originate in our process?


-- MARKET & COMPETITIVE INTELLIGENCE
-- · Which competitors are growing fastest in our target segments?
-- · Where are competitors hiring — what does that signal about direction?
-- · How is our pricing positioned relative to the market?
-- · Which customer segments are competitors targeting most aggressively?
-- · What features or capabilities are competitors investing in?
-- · Where are the underserved gaps in the current market landscape?
-- · How has market share shifted over the past 12-24 months?
-- · Which geographies or verticals represent the best expansion opportunity?
-- · What do job postings tell us about competitor product strategy?
-- · How does our customer satisfaction compare to industry benchmarks?


-- ============================================
-- WHAT MAKES A GOOD BUSINESS QUESTION?
-- ============================================
-- ✓ Answerable with data you actually have
-- ✓ Connected to a decision someone needs to make
-- ✓ Specific enough to write a clear query for
-- ✓ Has a so-what — the answer changes something
-- ✓ Benchmarkable — good vs bad is definable
--
-- AVOID QUESTIONS LIKE:
-- ✗ "Tell me everything about customers" — too broad
-- ✗ "What does the data show?" — no hypothesis
-- ✗ "Can we analyse revenue?" — not a question
-- ✗ "What is interesting?" — no direction
--
-- THE TEST:
-- Before writing any SQL ask yourself:
-- "If I get the answer — what decision does it inform?"
-- If you can't answer that — reframe the question first.
-- ============================================