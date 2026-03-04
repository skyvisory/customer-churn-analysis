# Customer Churn Analysis — Executive Summary
**Telco Customer Retention Strategy**
Prepared by: Skyvisory
Date: March 2026

---

## The Business Problem

A telecommunications company is losing **26.5% of its customers annually** —
above the 25% industry benchmark. With average monthly charges of **$64.76**
and average customer tenure of **32 months**, each churned customer represents
approximately **$1,332 in lost annual revenue**.

This analysis identifies who is churning, why they are churning, and
prescribes a targeted retention strategy with a projected **279% ROI**.

---

## Key Findings

### 1. Contract Type is the Strongest Churn Driver
Month-to-month customers churn at **42.7%** — 15x higher than two-year
contract customers at **2.8%**. Contract type is the single most powerful
predictor of churn across all analytical methods — SQL, correlation
analysis, and machine learning models all agree.

**Implication:** Converting month-to-month customers to annual contracts
is the highest leverage retention action available.

### 2. The First 12 Months are Critical
Customers in their first year churn at **47%** — the highest of any tenure
group. Churn drops dramatically to **9%** for customers who stay beyond
48 months. Retention is fundamentally an onboarding problem.

**Implication:** Invest disproportionately in the first 90 days of the
customer relationship.

### 3. Fiber Optic Customers are the Highest Risk Premium Segment
Fiber optic customers churn at **41.1%** — more than double the DSL rate
of **19%**. These are also the highest paying customers at an average of
**$91/month**. Premium customers have premium expectations — and are
leaving when those expectations aren't met.

**Implication:** Product quality and support for fiber optic customers
requires immediate attention.

### 4. Payment Method is a Proxy for Commitment
Electronic check customers churn at **45%** — nearly 3x the rate of
autopay customers at **15-17%**. Customers who manually pay each month
are making an active monthly decision to stay.

**Implication:** Incentivise autopay enrollment as part of onboarding.

### 5. Add-On Services Dramatically Reduce Churn
Customers with online security, tech support, and online backup churn
at significantly lower rates. These services embed customers deeper
into the ecosystem — increasing switching costs.

**Implication:** Bundle add-on services into retention offers.

### 6. A High-Risk Customer Profile Exists
Customers who are simultaneously on month-to-month contracts, fiber
optic internet, and electronic check payment churn at **60.4%** —
more than double the overall rate. This segment represents
**1,307 customers** and **$1.45M of the $1.67M total revenue at risk**.

---

## Revenue at Risk

| Segment | Customers | Churn Rate | Annual Revenue at Risk |
|---|---|---|---|
| Month-to-month | 3,875 | 42.7% | $1,454,621 |
| One year | 1,473 | 11.3% | $168,794 |
| Two year | 1,695 | 2.8% | $47,948 |
| **Total** | **7,043** | **26.5%** | **$1,671,363** |

---

## Methodology

Analysis conducted across four layers:

1. **SQL Exploration** — 10 business queries across 7,043 customer records
   identifying churn drivers, confounding variables, and Simpson's Paradox
   in services data
2. **Python Visualisation** — 12 charts translating SQL findings into
   executive-ready visuals
3. **Correlation Analysis** — ranked all 18 features by predictive power.
   Contract type (r=-0.397) and tenure (r=-0.352) confirmed as strongest
   predictors
4. **Machine Learning** — three models trained and compared. Logistic
   regression selected as primary model (AUC=0.845, Recall=0.77).
   Identified and resolved multicollinearity between tenure and
   totalcharges (r=0.829) by engineering avg_monthly_spend feature

---

## The Retention Model

A logistic regression model scores every customer with a churn probability
between 0 and 1. The model achieves:

| Metric | Value | Interpretation |
|---|---|---|
| AUC | 0.845 | 84.5% chance of ranking a churner above a non-churner |
| Recall | 77% | Catches 77% of customers who will churn |
| Precision | 53% | 53% of flagged customers actually churn |
| F1 Score | 0.63 | Balanced precision-recall performance |

**Why logistic regression over more complex models:**
Random Forest (AUC=0.838) and XGBoost (AUC=0.832) showed no meaningful
improvement over logistic regression. Thorough feature engineering upstream
reduced the advantage of complex models. Logistic regression was selected
for its interpretability, speed, and stakeholder explainability.

---

## Retention Campaign Architecture

7,043 customers scored and segmented into three action tiers:

| Tier | Customers | Actual Churn Rate | Treatment | Cost/Customer |
|---|---|---|---|---|
| High Risk | 1,744 | 63% | Personal phone outreach | $50 |
| Medium Risk | 1,663 | 31% | Automated email sequence | $10 |
| Low Risk | 3,636 | 7% | Monthly newsletter | $2 |

### Campaign ROI Projection

| Tier | Total Cost | Customers Saved | Revenue Recovered | Net ROI | ROI% |
|---|---|---|---|---|---|
| High Risk | $87,200 | 330 | $322,020 | $234,820 | 269% |
| Medium Risk | $16,630 | 102 | $82,233 | $65,603 | 394% |
| Low Risk | $7,272 | 26 | $17,323 | $10,051 | 138% |
| **Total** | **$111,102** | **458** | **$421,576** | **$310,474** | **279%** |

**A $111,102 retention investment recovers $421,576 in annual revenue —
every $1 spent returns $3.79.**

---

## Recommended Actions

### Immediate (0-30 days)
1. **Launch High Risk outreach** — contact 1,744 customers via personal
   phone call. Offer: contract upgrade incentive + autopay enrollment
   discount. Owner: Retention team. SLA: 48 hours.

2. **Activate Medium Risk email sequence** — automated 3-touch email
   campaign for 1,663 customers. Offer: loyalty discount.
   Owner: Marketing automation.

### Short Term (30-90 days)
3. **Investigate fiber optic satisfaction** — 41% churn rate signals
   product or service quality issues. Conduct NPS survey specifically
   for fiber optic customers. Identify top complaints.

4. **Redesign onboarding programme** — 47% first-year churn indicates
   onboarding failure. Implement 90-day success programme with proactive
   check-ins at day 7, 30, and 90.

5. **Bundle add-on services** — online security and tech support
   dramatically reduce churn. Include one free month of each in new
   customer welcome package.

### Ongoing
6. **Re-score monthly** — churn risk is not static. Re-run model
   monthly and update tier assignments.

7. **Implement suppression rules** — one customer, one campaign,
   one treatment. 90-day suppression after any intervention.
   Higher tier always takes priority.

8. **Incentivise autopay enrollment** — electronic check customers
   churn at 3x the rate of autopay customers. Offer first month free
   or bill credit for autopay signup.

---

## Known Limitations & Future Improvements

- **Save rates assumed** — 30%/20%/10% based on industry benchmarks.
  Replace with actual historical conversion rates when available.
- **No customer satisfaction data** — NPS or CSAT scores would
  significantly improve model accuracy.
- **Static model** — retrain quarterly as customer behaviour evolves.
- **Pipeline refactor** — migrate to sklearn Pipeline for production
  deployment to bundle scaler and model into single deployable object.
- **Hyperparameter tuning** — GridSearchCV on XGBoost may yield
  marginal AUC improvement.

---

## Appendix — Model Feature Importance

Top predictors of churn in order of importance:

| Rank | Feature | Direction | Business Meaning |
|---|---|---|---|
| 1 | Contract type | Negative | Longer contract = much less churn |
| 2 | Tenure | Negative | Longer tenure = much less churn |
| 3 | Avg monthly spend | Positive | Higher spend = more price sensitive |
| 4 | Internet service | Positive | Fiber optic = highest risk |
| 5 | Payment method | Positive | Electronic check = highest risk |
| 6 | Online security | Negative | Add-on = more loyal |
| 7 | Tech support | Negative | Add-on = more loyal |
| 8 | Monthly charges | Positive | Higher bill = more likely to churn |
| 9 | Paperless billing | Positive | Digital customers shop around more |
| 10 | Senior citizen | Positive | Age effect confirmed |
```
