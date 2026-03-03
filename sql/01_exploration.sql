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

-- ============================================
-- 3. Churn rate by tenure group
-- Business question: When in the customer lifecycle are customers most likely to leave?
-- Hypothesis: Newer customers churn more — they haven't yet experienced full product value
-- Note: tenure is binned into groups using CASE WHEN to reveal lifecycle patterns vs raw numbers
-- ============================================
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

-- FINDING: Churn is front-loaded — 0-12 month customers churn at ~47% vs ~9% for 48+ month customers
-- INSIGHT: The churn cliff effect — survive year one and customers become significantly more loyal.
--          Retention problem is largely an onboarding problem
-- ACTION:  Invest heavily in first 90 day onboarding experience
--          Deploy proactive renewal campaign at month 11-12
--          Identify what loyal (48+ month) customers have in common and replicate that experience earlier
-- ============================================

-- ============================================
-- 4. Churn rate by internet service type
-- Business question: Does service type affect churn — and what does that tell us about product-market fit?
-- Hypothesis: Higher value services may have higher expectations leading to more churn when those expectations aren't met
-- ============================================
SELECT
    internetservice,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY internetservice
ORDER BY churn_rate DESC;

-- FINDING: Fiber optic customers churn at ~41% vs ~19% for DSL and ~7% for no internet service
-- INSIGHT: Premium customers are the highest churn risk — likely driven by price sensitivity, aggressive 
--          competitor targeting, and unmet expectations.
--          This is a revenue concentration risk, not just a volume problem
-- ACTION:  Investigate fiber optic customer satisfaction specifically — NPS scores, support tickets,
--          price vs competitor benchmarking.
--          Consider a loyalty programme targeting fiber optic customers in months 1-12
-- ============================================

-- ============================================
-- 5. Churn rate by payment method
-- Business question: Does payment method affect churn — and what does payment behavior tell us about 
--                   customer commitment level?
-- Hypothesis: Automatic payment customers are more passively committed — cancelling requires
--             deliberate action, reducing impulse churn
-- ============================================
SELECT
    paymentmethod,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY paymentmethod
ORDER BY churn_rate DESC;

-- FINDING: Electronic check customers churn at ~45% vs 15-17% for automatic payment customers —
--          a 3x difference driven by payment behavior
-- INSIGHT: Payment method is a proxy for commitment level.
--          Active payment customers (electronic check)  are reminded of cost every month — each cycle
--          is a cancellation opportunity. Autopay customers churn only when something goes seriously wrong.
--          This is passive vs active churn psychology.
-- ACTION:  Launch autopay migration campaign targeting electronic check customers — small incentive
--          (discount or free month) to switch.
--          Flag electronic check % as a leading churn indicator in monthly reporting dashboard
-- ============================================

-- ============================================
-- 6. Average monthly charges — churned vs retained
-- Business question: What is the financial profile of churned vs retained customers?
--                   How much revenue is churn costing?
-- Hypothesis: Churned customers likely pay more — price sensitivity may be a churn driver
-- Note: NULLIF handles 11 blank TotalCharges values identified in data profiling (00_data_profiling.sql)
--       ::NUMERIC casts VARCHAR to number for AVG()
-- Note: TRIM() required before NULLIF — blanks are single space characters ' ' not empty strings ''
--       discovered during query execution
-- ============================================
SELECT
    churn,
    ROUND(AVG(monthlycharges), 2) as avg_monthly_charges,
    ROUND(AVG(tenure), 1) as avg_tenure_months,
    ROUND(AVG(NULLIF(TRIM(totalcharges), '')::NUMERIC), 2) as avg_total_charges
FROM telco
GROUP BY churn;

-- FINDING: Churned customers pay ~$74/month vs ~$61 for retained — but stay only 18 months vs 
--          38 months for retained customers
-- INSIGHT: Higher paying customers are leaving faster — a revenue quality problem. Retained customer 
--          LTV is 67% higher ($2,555 vs $1,531).
--          Each churned customer = ~$1,332 lost revenue.
--          1,869 churned customers = ~$2.5M annual revenue at risk
-- ACTION:  Build a retention ROI model — even saving 10% of churners at $50/customer cost delivers
--          26x return. Present to CFO as investment, not cost centre
-- ============================================



-- ============================================
-- 7. Highest risk segment
-- Business question: What is the single highest risk customer profile when combining all churn drivers identified?
-- Hypothesis: Month-to-month + fiber optic + electronic check will be the highest risk combination
--             based on findings from queries 2, 4, and 5
-- Note: HAVING COUNT(*) > 50 removes statistically insignificant segments — only actionable 
--       segments with 50+ customers are shown HAVING filters after GROUP BY (vs WHERE before)
-- ============================================
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

-- FINDING: Month-to-month + fiber optic + electronic check customers churn at 60.37% across 1,307 customers
--          Top 4 highest risk segments all involve fiber optic confirming it as the primary product risk factor.
--          Electronic check adds ~15pp churn on top of any fiber optic combination
-- INSIGHT: This is not a general churn problem — it is a fiber optic product problem amplified
--          by payment behavior. Even one year contract fiber optic + electronic check churns at 26%.
--          Product dissatisfaction overrides contract commitment
-- ACTION:  Immediate outreach to 1,307 highest risk customers
--          Priority 1: autopay migration — highest ROI, lowest cost
--          Priority 2: contract upgrade offer
--          Priority 3: fiber optic service quality audit
--          Track these 4 segments monthly as primary churn KPIs
-- ============================================

-- ============================================
-- 8. Senior citizen churn comparison
-- Business question: Does age demographic affect churn rate — and does it change our retention approach?
-- Note: seniorcitizen is binary encoded (0/1 integer) not a text Yes/No field like other columns.
--       This is common in ML-ready datasets.
-- ============================================
SELECT
    seniorcitizen,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY seniorcitizen;

-- FINDING: Senior citizens (1) churn at ~42% vs ~24% for non-seniors (0) — nearly double the rate
--          Seniors represent ~16% of customers but a disproportionate share of churn
-- INSIGHT: Age correlation exists but causation is unclear. Seniors may be over-represented in high risk
--          segments (month-to-month, fiber optic, electronic check) rather than churning due to age itself.
--          Confounding variables must be investigated before building age-specific retention programmes
-- ACTION:  Run cross-tabulation of seniorcitizen vs contract type and payment method to test confounding.
--          If age is independent driver — build senior specific outreach programme (phone-based, simpler messaging).
--          If segment driven — prioritise seniors within existing high risk segment campaigns
-- ============================================

-- ============================================
-- 8b. Senior citizen confounding variable test
-- Business question: Are seniors churning because of age — or because they are over-represented in high risk
--                   segments identified in Query 7?
-- Method: Cross-tabulate seniorcitizen against the three key churn drivers to test whether
--         age is an independent driver or explained by segment membership
-- ============================================

-- TEST 1: Are seniors more likely to be on month-to-month contracts?
SELECT
    seniorcitizen,
    contract,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY seniorcitizen), 2) as pct_within_age_group
FROM telco
GROUP BY seniorcitizen, contract
ORDER BY seniorcitizen, pct_within_age_group DESC;

-- FINDING: Seniors are significantly more concentrated in month-to-month contracts (71% vs 52%
--          for non-seniors) and half as likely to be on two-year contracts (13% vs 26%).
-- INSIGHT: Contract type distribution partly explains higher senior churn.

-- TEST 2: Are seniors more likely to have fiber optic internet?
SELECT
    seniorcitizen,
    internetservice,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY seniorcitizen), 2) as pct_within_age_group
FROM telco
GROUP BY seniorcitizen, internetservice
ORDER BY seniorcitizen, pct_within_age_group DESC;

-- FINDING: 73% of seniors are on fiber optic vs only 38% of non-seniors. Seniors are nearly twice as likely 
--          to have fiber optic.
--          Only 5% of seniors have no internet service vs 25% of non-seniors.
--
-- INSIGHT: Seniors are heavily concentrated in fiber optic — the highest churn service type. Combined with
--          Test 1 (71% on month-to-month), seniors are systematically represented in every high risk
--          category simultaneously. This may reflect a sales motion that prioritised premium short-term
--          signups over long-term retention outcomes.
--
-- ACTION:  Investigate sales and onboarding process for senior customers specifically. Were seniors
--          actively sold fiber optic month-to-month?
--          If so, retention problem may have a sales process root cause worth addressing upstream.
-- ============================================


-- TEST 3: Are seniors more likely to pay by electronic check?
SELECT
    seniorcitizen,
    paymentmethod,
    COUNT(*) as total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY seniorcitizen), 2) as pct_within_age_group
FROM telco
GROUP BY seniorcitizen, paymentmethod
ORDER BY seniorcitizen, pct_within_age_group DESC;

-- FINDING: 52% of seniors pay by electronic check vs only 30% of non-seniors. More than half of all senior customers 
--          are on the highest churn payment method. Seniors are also significantly less likely to use mailed
--          check (8% vs 26%) suggesting a different demographic and behavioral profile entirely
--
-- INSIGHT: All three tests confirm seniors are systematically over-represented in every high risk category:
--          Month-to-month: 71% vs 52% (+19pp)
--          Fiber optic: 73% vs 38% (+35pp)
--          Electronic check: 52% vs 30% (+22pp)
--          This pattern is too consistent to be coincidental — likely reflects a sales motion that placed seniors
--          in premium flexible plans without adequate retention safeguards
--
-- ACTION:  Audit senior customer acquisition and onboarding process. 
--          Identify which sales channels and reps are generating senior month-to-month fiber optic signups.
--          Consider commission structure changes that reward long-term contract signups over short-term flexible ones.
-- ============================================


-- ============================================
-- TEST 4: Definitive confounding test — churn rate of seniors vs non-seniors within the same contract type
-- Business question: If we control for contract type does the senior churn gap disappear?
--                   Or does age remain an independent driver regardless of contract?
-- Hypothesis: If age is purely explained by segment membership — the churn gap between seniors
--             and non-seniors should disappear or shrink dramatically within identical contract types.
--             If age is independent — the gap persists even on identical contracts.
-- Method: Compare churn rates of seniors vs non-seniors within each contract type separately.
--         Contract type chosen as the control variable because it was the strongest churn driver
--         found in Query 2 (15x difference)
-- ============================================
SELECT
    seniorcitizen,
    contract,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
GROUP BY seniorcitizen, contract
ORDER BY contract, seniorcitizen;

-- FINDING: Seniors churn more than non-seniors across every single contract type:
--          Month-to-month: 54.65% vs 39.57% (+15pp gap)
--          One year:       15.26% vs 10.68% (+5pp gap)
--          Two year:        4.14% vs  2.71% (+1.4pp gap)
--
-- INSIGHT: Age IS an independent churn driver — the gap persists even when contract type is identical.
--          However the gap shrinks dramatically as contract length increases:
--          · Month-to-month gap: 15pp — age effect strong
--          · One year gap: 5pp — age effect weakening
--          · Two year gap: 1.4pp — age effect almost gone
--          Getting a senior onto a two-year contract nearly eliminates the age churn effect entirely.
--          Senior retention strategy and contract upgrade strategy are therefore the same strategy.
--
-- ACTION:  Prioritise contract upgrade campaigns targeting senior citizens specifically.
--          Messaging angle: stability, predictable pricing, no annual rate increases on fixed contracts.
--          Expected outcome: reduces senior churn from 54.65% toward 4.14% if moved to two-year contract
--          That is a 50 percentage point churn reduction from a single intervention.
-- ============================================


-- ============================================
-- CONFOUNDING VARIABLE COMPLETE SUMMARY
-- ============================================
-- ORIGINAL QUESTION:
-- Query 8 found seniors churn at 42% vs 24% for non-seniors. 
-- Is age the real driver — or are seniors just over-represented in high risk segments?
--
-- TESTS CONDUCTED:
-- Test 1: Contract distribution by age group
-- Test 2: Internet service distribution by age group
-- Test 3: Payment method distribution by age group
-- Test 4: Churn rate within identical contract types
--
-- STRUCTURAL FINDINGS (Tests 1-3):
-- Seniors are over-represented in every high risk segment simultaneously:
-- · 71% on month-to-month vs 52% non-seniors (+19pp)
-- · 73% on fiber optic vs 38% non-seniors (+35pp)
-- · 52% on electronic check vs 30% non-seniors (+22pp)
-- Note: overall manual vs auto payment split is similar between seniors (60%) and non-seniors (56%) — the
-- real difference is seniors concentrated in electronic check specifically vs mailed check for non-seniors.
-- Electronic check is the high churn manual payment. Mailed check is the low churn manual payment.
-- This reflects a generational shift toward digital payments without full commitment to autopay.
--
-- AGE EFFECT FINDING (Test 4):
-- Even within identical contract types seniors churn more — confirming age IS an independent driver.
-- Gap is largest on month-to-month (+15pp) and shrinks to near zero on two-year contracts (+1.4pp).
--
-- VERDICT: Both structural AND age effects are real.
-- Two parallel interventions required:
--
-- INTERVENTION 1 — UPSTREAM (structural fix)
-- Audit sales and onboarding process for seniors.
-- Seniors are being systematically placed in premium flexible plans — likely a sales incentive issue.
-- Restructure commissions to reward long-term contracts.
-- Expected impact: reduces future senior risk concentration
--
-- INTERVENTION 2 — DOWNSTREAM (retention fix)
-- Senior specific contract upgrade campaign.
-- Priority segment: senior + month-to-month + fiber optic + electronic check
-- Messaging: stability, predictable pricing, simplicity
-- Nudge to autopay as part of contract upgrade bundle
-- Seniors already comfortable with digital payments (electronic check) — autopay nudge is smaller than
-- it appears
-- Expected impact: reduces senior churn from 54.65% toward 4.14% — a 50 percentage point improvement
-- from a single targeted intervention
--
-- OVERALL VERDICT:
-- Senior churn is a solvable high ROI problem.
-- Concentrated, identifiable, and addressable through two specific parallel interventions targeting both
-- the root cause and the immediate retention opportunity.
-- ============================================


-- ============================================
-- 9. Churn rate by number of services subscribed
-- Business question: Does subscribing to more services create loyalty — and what is the magic number of services 
--                   that meaningfully reduces churn?
-- Hypothesis: More services = higher switching cost = lower churn.
--             Each additional service embeds the customer deeper in the ecosystem
-- Note: services_count is a engineered feature — summing binary CASE WHEN across 8 service
--       columns to create a single numeric variable. Same pattern used in ML feature engineering.
--       internetservice uses != 'No' not = 'Yes' because it has 3 values (DSL, Fiber optic, No)
-- ============================================
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

-- FINDING: Non-linear relationship between services and churn.
--          Services count 1 anomalously low at 9.22% — explained by 1,526 phone-only customers (no internet)
--          who are a distinct low-churn demographic (Query 9b).
--          Excluding anomaly, clear downward trend from 51.58% at 2 services to 5.79% at 8 services.
--          Inflection point at 7 services — churn drops from 22.01% to 12.57% — the magic number threshold.
--
-- INSIGHT: Simpson's Paradox effect at services_count=1 — phone-only customers dominate and distort the
--          aggregate masking the true services-churn relationship.
--          Real story: every additional service reduces churn consistently. Cross-sell is not just a revenue play —
--          it is the most powerful retention tool in the business.
--          Customers in the 2-6 service range are the danger zone — engaged enough to have multiple services but not
--          embedded enough to stay without intervention.
--
-- ACTION:  Prioritise cross-sell campaigns targeting customers in the 2-5 service range before they churn.
--          Goal: move customers to 7+ services threshold where churn drops to single digits.
--          Frame expansion selling internally as retention investment not just revenue growth.
--          Do not disturb phone-only segment — they are stable, low cost, and extremely loyal.
-- ============================================


-- ============================================
-- 9b. Diagnose single service customers
-- Business question: Why do single service customers have anomalously low churn?
--                   Are they a genuinely loyal segmen or a statistical anomaly?
-- Hypothesis: Single service customers may be phone-only older customers with no internet service —
--             a completely different profile to internet subscribers
-- ============================================
SELECT
    phoneservice,
    internetservice,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate
FROM telco
WHERE (CASE WHEN phoneservice = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN internetservice != 'No' THEN 1 ELSE 0 END +
       CASE WHEN onlinesecurity = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN onlinebackup = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN deviceprotection = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN techsupport = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN streamingtv = 'Yes' THEN 1 ELSE 0 END +
       CASE WHEN streamingmovies = 'Yes' THEN 1 ELSE 0 END) = 1
GROUP BY phoneservice, internetservice
ORDER BY total_customers DESC;

-- FINDING: 1,526 of 1,606 single service customers are phone-only with no internet (7.40% churn).
--          Remaining 80 are DSL-only with no phone (43.75% churn).
--          Two completely different profiles within same count.
--
-- INSIGHT: Phone-only customers are a hidden stable segment — likely older, long-tenured, basic plan customers
--          with no exposure to fiber optic (highest churn product).
--          Their loyalty is structural — not because of engagement but because of simplicity and lack of alternatives.
--          DSL-only customers behave normally — 43.75% aligns with expected churn for low service count customers.
--          Simpson's Paradox confirmed — phone-only dominance distorts the services_count=1 aggregate result.
--
-- ACTION:  Treat phone-only segment separately in all analysis. They are not comparable to internet subscribers.
--          Consider as a separate customer cohort with its own retention and growth strategy.
--          Opportunity: gentle upsell of basic internet package to phone-only customers could significantly increase
--          LTV without disrupting their loyalty profile.
-- ============================================

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