# Customer Churn Analysis — Executive Summary
**Telco Customer Retention Strategy**
Prepared by: Skyvisory | March 2026

---

## The Business Problem

A telecommunications company is losing **26.5% of its customers annually** —
above the 25% industry benchmark. With average monthly charges of **$64.76**
and average customer tenure of **32 months**, each churned customer represents
approximately **$1,332 in lost annual revenue**.

SQL analysis of 7,043 customer records identified the key drivers of churn,
confirmed by machine learning models. This report presents a targeted
retention strategy with a projected **279% ROI**.

---

## Key Findings

### 1. Contract Type is the Strongest Churn Driver
SQL analysis of contract types revealed month-to-month customers churn at
**42.7%** — 15x higher than two-year contract customers at **2.8%**.
This finding was independently confirmed as the strongest predictor across
correlation analysis (r=-0.397) and both machine learning models.

**Implication:** Converting month-to-month customers to annual contracts
is the single highest leverage retention action available.

### 2. The First 12 Months are Critical
SQL cohort analysis revealed customers in their first year churn at **47%**
— the highest of any tenure group. Churn drops dramatically to **9%** for
customers beyond 48 months. The machine learning model confirmed tenure
as the second strongest churn predictor (r=-0.352).

**Implication:** Retention is fundamentally an onboarding problem.
Invest disproportionately in the first 90 days.

### 3. Fiber Optic Customers are the Highest Risk Premium Segment
SQL analysis identified fiber optic customers churning at **41.1%** —
more than double the DSL rate of **19%**. These are also the highest
paying customers at an average of **$91/month**. The machine learning
model confirmed internet service type as the fourth strongest predictor
of churn.

**Implication:** Premium customers have premium expectations.
Product quality and support for fiber optic requires immediate attention.

### 4. Payment Method is a Proxy for Commitment
SQL analysis of payment behaviour found electronic check customers
churning at **45%** — nearly 3x the rate of autopay customers at
**15-17%**. Customers who manually pay each month are making an active
monthly decision to stay — a behavioural signal of low commitment.

**Implication:** Incentivise autopay enrollment as a priority
during onboarding and retention outreach.

### 5. Add-On Services Dramatically Reduce Churn
SQL analysis confirmed customers with online security, tech support,
and online backup churn at significantly lower rates. Correlation
analysis ranked online security (r=-0.289) and tech support (r=-0.282)
as the third and fourth strongest protective factors against churn.
These services embed customers deeper into the ecosystem —
increasing switching costs organically.

**Implication:** Bundle add-on services into new customer welcome
packages and retention offers.

### 6. Senior Citizens are a Disproportionately At-Risk Segment
SQL analysis identified senior citizens churning at **41.7%** vs
**23.6%** for non-seniors. Importantly, further SQL investigation
confirmed this effect persists even after controlling for contract
type and service tier — seniors are at elevated risk independent of
other factors. At **16.2% of the customer base**, this represents
a meaningful and addressable segment.

**Implication:** Senior customers require dedicated outreach that
accounts for their specific needs — simpler contracts, assisted
autopay enrollment, and proactive tech support.

### 7. A High-Risk Customer Profile Exists
SQL Query 7 identified customers simultaneously on month-to-month
contracts, fiber optic internet, and electronic check payment
churning at **60.4%** — more than double the overall rate.
This segment represents **1,307 customers** and
**$1.45M of the $1.67M total revenue at risk**.

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

1. **SQL Exploration** — 10 business queries across 7,043 customer
   records identifying churn drivers, confounding variables, and
   high-risk customer profiles. Included detection of Simpson's Paradox
   in services data — where aggregate churn rates masked opposing
   trends within subgroups.

2. **Python Visualisation** — 12 charts translating SQL findings into
   executive-ready visuals across contract type, tenure, internet
   service, payment method, and revenue at risk.

3. **Correlation Analysis** — ranked all 18 features by predictive
   power. Contract type (r=-0.397) and tenure (r=-0.352) confirmed
   as strongest predictors. Gender (r=-0.009) and phone service
   (r=+0.012) identified as non-predictive and excluded from modelling.

4. **Machine Learning** — three models trained and compared.
   Logistic regression selected as primary model (AUC=0.845,
   Recall=0.77). Multicollinearity between tenure and totalcharges
   (r=0.829) identified and resolved by engineering avg_monthly_spend
   feature — capturing pure spend signal independent of tenure.

---

## The Retention Model

A logistic regression model scores every customer with a churn
probability between 0 and 1. The model achieves:

| Metric | Value | Interpretation |
|---|---|---|
| AUC | 0.845 | 84.5% chance of ranking a churner above a non-churner |
| Recall | 77% | Catches 77% of customers who will churn |
| Precision | 53% | 53% of flagged customers actually churn |
| F1 Score | 0.63 | Balanced precision-recall performance |

**Why logistic regression over more complex models:**
Random Forest (AUC=0.838) and XGBoost (AUC=0.832) showed no meaningful
improvement over logistic regression. Thorough feature engineering
upstream reduced the advantage of complex models. Logistic regression
was selected for interpretability, speed, and stakeholder explainability.

---

## Retention Campaign Architecture

7,043 customers scored and segmented into three action tiers based on
data-validated probability thresholds (0.40 and 0.70):

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

**A $111,102 retention investment recovers $421,576 in annual
revenue — every $1 spent returns $3.79.**

---

## Recommended Actions

### Immediate (0-30 days)

**1. Launch High Risk personal outreach — 1,744 customers:**
Contact via personal phone call within 48 hours.
- Primary offer: contract upgrade incentive (month-to-month → one year)
- Secondary offer: autopay enrollment discount
- For senior citizens in this tier: assign dedicated agent,
  simplify contract language, offer assisted autopay setup
- Owner: Retention team
- Suppression: 90 days after contact

**2. Activate Medium Risk automated email sequence — 1,663 customers:**
Three-touch automated campaign over 14 days.
- Primary offer: loyalty discount
- For senior citizens in this tier: plain language email template,
  include phone number for assisted support
- For electronic check customers: autopay enrollment incentive
  as primary call to action
- Owner: Marketing automation
- Suppression: 90 days after first touch

**3. Maintain Low Risk newsletter — 3,636 customers:**
Monthly engagement touchpoint — no retention offer needed.
- Content: product updates, tips, community news
- For senior citizens in this tier: proactive tech support
  check-in every 6 months
- Owner: Content team

### Short Term (30-90 days)

**4. Investigate fiber optic satisfaction:**
41% churn rate signals product or service quality issues.
Conduct NPS survey specifically for fiber optic customers.
Identify top complaints — speed, reliability, or support quality.
Cross-reference with senior citizen segment — seniors on fiber
optic churn at the intersection of two high-risk factors.

**5. Redesign onboarding programme:**
47% first-year churn indicates onboarding failure.
Implement 90-day success programme with proactive check-ins
at day 7, 30, and 90. For senior citizens — assign a dedicated
onboarding contact for the first 90 days.

**6. Bundle add-on services in welcome package:**
Online security and tech support dramatically reduce churn.
Include one free month of each in new customer welcome package.
Particularly valuable for senior citizens — tech support
add-on addresses a known pain point and reduces churn risk.

### Ongoing

**7. Re-score monthly:**
Churn risk is not static. Re-run model monthly and update
tier assignments. Senior citizens who upgrade to annual
contracts should be re-scored and moved to lower risk tiers.

**8. Implement suppression rules:**
One customer, one campaign, one treatment.
Higher tier always takes priority.
90-day suppression after any intervention prevents
offer fatigue and campaign interference.

**9. Incentivise autopay enrollment at every touchpoint:**
Electronic check customers churn at 3x the rate of autopay
customers. Offer first month free or bill credit for autopay
signup — include in onboarding, retention calls, and email
campaigns. For senior citizens — offer assisted enrollment
via phone as default option.

---

## Known Limitations & Future Improvements

- **Save rates assumed** — 30%/20%/10% based on industry benchmarks.
  Replace with actual historical conversion rates when available.
- **No customer satisfaction data** — NPS or CSAT scores would
  significantly improve model accuracy, particularly for
  understanding fiber optic dissatisfaction drivers.
- **Senior citizen context incomplete** — age alone does not explain
  churn. Additional data on support call frequency, billing confusion,
  or service complexity would strengthen targeting.
- **Static model** — retrain quarterly as customer behaviour evolves.
- **Pipeline refactor** — migrate to sklearn Pipeline for production
  deployment.
- **Hyperparameter tuning** — GridSearchCV on XGBoost may yield
  marginal AUC improvement.

---

## Appendix — Model Feature Importance

Top predictors of churn in order of importance:

| Rank | Feature | Direction | Business Meaning |
|---|---|---|---|
| 1 | Contract type | Decreases churn | Longer contract = much less churn |
| 2 | Tenure | Decreases churn | Longer tenure = much less churn |
| 3 | Avg monthly spend | Increases churn | Higher spend = more price sensitive |
| 4 | Internet service | Increases churn | Fiber optic = highest risk |
| 5 | Payment method | Increases churn | Electronic check = highest risk |
| 6 | Online security | Decreases churn | Add-on = more loyal |
| 7 | Tech support | Decreases churn | Add-on = more loyal |
| 8 | Monthly charges | Increases churn | Higher bill = more likely to churn |
| 9 | Paperless billing | Increases churn | Digital customers shop around more |
| 10 | Senior citizen | Increases churn | Elevated risk independent of other factors |
```

---

**Three changes from previous version:**

**SQL woven in:** Each finding now references where it came from — "SQL analysis revealed", "SQL cohort analysis", "correlation analysis confirmed" — builds a narrative of layered evidence rather than just stating conclusions.

**Senior citizen interweaved:** Added to every relevant recommendation action without creating a separate campaign — seniors in High Risk get dedicated agent, seniors in Medium Risk get plain language templates, seniors in Low Risk get proactive check-ins. One customer, one campaign — suppression rules prevent overlap automatically.

**Simpson's Paradox:** One line in methodology only — "detection of Simpson's Paradox in services data where aggregate churn rates masked opposing trends within subgroups." Signals analytical rigour without confusing a non-technical audience.
