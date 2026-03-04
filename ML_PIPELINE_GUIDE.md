# ML Pipeline Guide
A reference guide for building end-to-end ML pipelines on tabular data.
Built from the Customer Churn Analysis project.
Apply this pattern to any binary classification problem.

---

## The Universal ML Pipeline
```
Raw Data
    ↓ 1. Exploratory Analysis    — understand before modelling
    ↓ 2. Data Cleaning           — fix quality issues
    ↓ 3. Feature Engineering     — prepare for ML
    ↓ 4. Model Training          — fit and evaluate
    ↓ 5. Model Selection         — pick the best model
    ↓ 6. Scoring                 — score all customers
    ↓ 7. Business Translation    — turn scores into actions
Actionable Scorecard
```

---

## 1. Exploratory Analysis

Always explore before modelling. SQL is the best tool for this.
```sql
-- Profile every column
SELECT
    COUNT(*) as total_rows,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) as churn_rate
FROM telco;
```

**Key questions to answer before modelling:**
- What is the target variable distribution? (class balance)
- Which features correlate most with the target?
- Are there nulls, outliers, or data quality issues?
- Are there confounding variables?
- Does Simpson's Paradox affect any findings?

---

## 2. Data Cleaning
```python
# Standard cleaning checklist
df.info()        # data types and nulls
df.describe()    # statistical summary
df.head()        # visual sanity check

# Fix common issues
df['col'] = pd.to_numeric(df['col'].str.strip(), errors='coerce').fillna(0)
df['target'] = df['target'].map({'Yes': 1, 'No': 0})
df.columns = df.columns.str.lower().str.strip()
df = df.drop('id_column', axis=1)
```

**Common issues and fixes:**

| Issue | Fix |
|---|---|
| Numeric stored as text | `pd.to_numeric(col.str.strip(), errors='coerce')` |
| Text target variable | `.map({'Yes': 1, 'No': 0})` |
| Inconsistent column names | `.str.lower().str.strip()` |
| ID columns | Drop — not a predictive feature |
| Null values | `.fillna(0)` or `.fillna(median)` depending on context |

---

## 3. Feature Engineering

### Order matters — always engineer before scaling
```
Raw data
    ↓ Engineer new features    ← must be first
    ↓ Drop irrelevant columns  ← correlation < 0.05
    ↓ Separate X and y
    ↓ One-hot encode
    ↓ Scale numeric features
    ↓ Train/test split
Prepared data
```

### Drop irrelevant features
```python
# Use correlation analysis to identify weak features
corr_matrix = df_encoded.corr()
churn_corr = corr_matrix['target'].drop('target')
churn_corr = churn_corr.sort_values(ascending=False)

# Drop features with near-zero correlation
cols_to_drop = churn_corr[churn_corr.abs() < 0.05].index.tolist()
df = df.drop(cols_to_drop, axis=1)
```

### Check for multicollinearity before engineering
```python
# High correlation between features = redundant information
corr_matrix = df[numeric_cols].corr()

# If two features correlate > 0.8 — consider engineering
# a new feature that combines them more meaningfully
# Example: totalcharges / tenure = avg_monthly_spend
df['avg_monthly_spend'] = df.apply(
    lambda x: x['totalcharges'] / x['tenure']
    if x['tenure'] > 0 else x['monthlycharges'],
    axis=1
)
df = df.drop('totalcharges', axis=1)
```

### Separate X and y — always before encoding
```python
# Must happen AFTER all feature engineering
X = df.drop('target', axis=1)
y = df['target']
```

### One-hot encode categorical features
```python
# pd.get_dummies — simplest approach
X_encoded = pd.get_dummies(X, drop_first=True)

# drop_first=True prevents dummy variable trap
# n categories → n-1 columns
# reference category is implied when all dummies = 0
```

**Label encoding vs one-hot encoding:**

| Method | Use when | Warning |
|---|---|---|
| `LabelEncoder` | Ordinal categories (low/medium/high) | Implies false order for nominal categories |
| `pd.get_dummies` | Nominal categories (contract type) | Always use for non-ordered categories |
| `OrdinalEncoder` | Explicitly ordered categories | Must specify order manually |

### Scale numeric features
```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_scaled = X_encoded.copy()
X_scaled[numeric_cols] = scaler.fit_transform(X_scaled[numeric_cols])

# Save scaler — must use same scaler for scoring
import pickle
with open('data/processed/scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)
```

**Which scaler to use:**

| Scaler | Use when |
|---|---|
| `StandardScaler` | Default — most ML models, some outliers ok |
| `MinMaxScaler` | Neural networks, need bounded 0-1 range |
| `RobustScaler` | Heavy outliers that are meaningful data points |

**Golden rule:** Never refit scaler on scoring data.
Always use `.transform()` not `.fit_transform()` at inference time.

### Train/test split
```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y,
    test_size=0.2,       # 80/20 split
    random_state=42,     # reproducibility
    stratify=y           # preserve class ratio
)
```

**Why stratify=y matters:**
Guarantees same class ratio in both sets.
Critical for imbalanced datasets — without it
test set may have very different churn rate than training.

---

## 4. Model Training

### Always start with Logistic Regression
```python
from sklearn.linear_model import LogisticRegression

lr_model = LogisticRegression(
    random_state=42,
    max_iter=1000,           # increase if ConvergenceWarning
    class_weight='balanced'  # critical for imbalanced data
)

lr_model.fit(X_train, y_train)
lr_pred = lr_model.predict(X_test)
lr_prob = lr_model.predict_proba(X_test)[:, 1]
```

### Then try Random Forest
```python
from sklearn.ensemble import RandomForestClassifier

rf_model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=10,
    min_samples_leaf=4,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1
)
```

### Then try XGBoost
```python
from xgboost import XGBClassifier

# Calculate class imbalance ratio
neg = (y_train == 0).sum()
pos = (y_train == 1).sum()
scale = neg / pos

xgb_model = XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    subsample=0.8,
    colsample_bytree=0.8,
    scale_pos_weight=scale,  # handles class imbalance
    random_state=42,
    eval_metric='auc',
    verbosity=0
)
```

### Model progression
```
Step 1: Logistic Regression  → baseline
Step 2: Random Forest        → handles non-linearity
Step 3: XGBoost              → industry standard
Step 4: Hyperparameter tuning → optimise best model
Step 5: Ensemble             → combine models (optional)
```

---

## 5. Model Evaluation

### The four evaluation metrics
```python
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score,
    roc_curve
)

print(classification_report(y_test, pred,
      target_names=['Retained', 'Churned']))
print(f"ROC-AUC: {roc_auc_score(y_test, prob):.4f}")
```

### Understanding the confusion matrix
```
                PREDICTED
            Retained  Churned
ACTUAL  Retained  TN      FP
        Churned   FN      TP

TN = predicted retained, actually retained ✅
TP = predicted churned, actually churned   ✅
FP = predicted churned, actually retained  ❌ false alarm
FN = predicted retained, actually churned  ❌ missed churner
```

### The four metrics explained
```
Precision = TP / (TP + FP)
→ Of everyone flagged — how many were right?
→ "Can I trust the alarm?"

Recall = TP / (TP + FN)
→ Of everyone who churned — how many did we catch?
→ "Does the alarm go off when it should?"

F1 = 2 × (Precision × Recall) / (Precision + Recall)
→ Harmonic mean — only high when BOTH are high
→ Punishes extreme imbalance between precision and recall

AUC = Area under ROC curve
→ Probability model ranks random churner above random non-churner
→ 0.50 = random, 0.84 = strong, 1.0 = perfect
```

### Which metric to prioritise

| Business problem | Priority metric | Reason |
|---|---|---|
| Churn prevention | Recall | Missing churner costs more than false alarm |
| Fraud detection | Precision | False accusations are costly |
| Medical diagnosis | Recall | Missing disease is worse than false positive |
| Spam filter | Precision | Blocking real emails is worse than missing spam |
| Balanced problem | F1 | Neither error is worse than the other |

### AUC benchmarks
```
0.50 → random guessing
0.70 → acceptable
0.80 → good
0.85 → strong
0.90 → excellent
0.95 → outstanding
1.00 → perfect (check for data leakage)
```

---

## 6. Feature Importance

### Logistic Regression — coefficients
```python
lr_importance = pd.Series(
    lr_model.coef_[0],
    index=X_train.columns
).sort_values()

# Positive coefficient → increases churn probability
# Negative coefficient → decreases churn probability
```

### Random Forest — mean decrease in impurity
```python
rf_importance = pd.Series(
    rf_model.feature_importances_,
    index=X_train.columns
).sort_values(ascending=False)

# Higher = more important for prediction
# Always positive — no direction information
```

### When both models agree — high confidence finding
```
If LR coefficient is high AND RF importance is high
→ Feature is genuinely important
→ Safe to include in recommendations
→ Robust finding across different model types
```

---

## 7. Scoring New Data

### The scoring pipeline — must mirror training exactly
```python
# Step 1 — Apply same cleaning
df_score['totalcharges'] = pd.to_numeric(...)

# Step 2 — Apply same feature engineering
df_score['avg_monthly_spend'] = df_score.apply(...)
df_score = df_score.drop('totalcharges', axis=1)

# Step 3 — Drop same columns
df_score = df_score.drop(['id', 'target', 'gender'], axis=1)

# Step 4 — Apply same encoding
df_score_encoded = pd.get_dummies(df_score, drop_first=True)

# Step 5 — Align columns with training data
df_score_encoded = df_score_encoded.reindex(
    columns=X_train.columns, fill_value=0
)

# Step 6 — Scale using ORIGINAL scaler
with open('data/processed/scaler.pkl', 'rb') as f:
    original_scaler = pickle.load(f)

df_score_encoded[numeric_cols] = original_scaler.transform(
    df_score_encoded[numeric_cols]
)

# Step 7 — Generate probabilities
probabilities = model.predict_proba(df_score_encoded)[:, 1]
```

### The golden rules of scoring
```
1. Same cleaning      → identical preprocessing
2. Same engineering   → identical feature creation
3. Same columns       → reindex to match training
4. Same scaler        → load original, never refit
5. Same model         → load saved model object
```

### Production improvement — use sklearn Pipeline
```python
from sklearn.pipeline import Pipeline

# Bundles scaler and model — can never use wrong scaler
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model',  LogisticRegression())
])

pipeline.fit(X_train_raw, y_train)
probabilities = pipeline.predict_proba(X_test_raw)[:, 1]

# Save everything as one object
with open('churn_pipeline.pkl', 'wb') as f:
    pickle.dump(pipeline, f)
```

---

## 8. Building a Risk Scorecard

### Explore probability distribution first
```python
# Look at distribution BEFORE setting thresholds
plt.hist(probabilities, bins=50)
plt.show()

# Check percentiles to inform threshold selection
for p in [50, 60, 70, 75, 80, 90]:
    val = np.percentile(probabilities, p)
    count = (probabilities >= val).sum()
    print(f"Top {100-p}% → {count:,} customers "
          f"→ probability >= {val:.2f}")
```

### Assign risk tiers
```python
def assign_risk_tier(prob):
    if prob >= 0.70:    # data driven threshold
        return 'High Risk'
    elif prob >= 0.40:  # data driven threshold
        return 'Medium Risk'
    else:
        return 'Low Risk'

scorecard['risk_tier'] = scorecard['churn_probability'].apply(
    assign_risk_tier
)
```

### Validate tiers with actual outcomes
```python
# Actual churn rate should differ significantly across tiers
# If not — thresholds need adjustment
validation = scorecard.groupby('risk_tier')['actual_churn'].mean()
print(validation)

# Good separation example:
# High Risk:   63% actual churn
# Medium Risk: 31% actual churn
# Low Risk:     7% actual churn
# → 9x difference = strong model
```

---

## 9. Campaign Architecture

### Suppression rules — prevent campaign interference
```
1. One customer = one campaign = one treatment
2. Higher tier takes priority
3. 90 day suppression after any intervention
4. Re-score monthly — tiers are not permanent
```

### ROI calculation template
```python
total_cost      = customers × cost_per_customer
actual_churners = customers × actual_churn_rate
customers_saved = actual_churners × save_rate
revenue         = customers_saved × monthly_charges × 12
net_roi         = revenue - total_cost
roi_pct         = net_roi / total_cost × 100
```

### Standard save rates by intervention type

| Intervention | Cost | Save Rate |
|---|---|---|
| Personal phone call | $40-60 | 25-35% |
| Automated email sequence | $8-15 | 15-25% |
| SMS campaign | $3-8 | 10-20% |
| Newsletter / mass comms | $1-3 | 5-15% |

---

## 10. Common Mistakes to Avoid

| Mistake | Fix |
|---|---|
| Feature engineering after scaling | Always engineer on raw values first |
| Refitting scaler at inference | Load original scaler with pickle |
| No stratify in train/test split | Always use stratify=y for classification |
| Using accuracy for imbalanced data | Use AUC and recall instead |
| Dropping all correlated features | Engineer a combined feature instead |
| Setting thresholds arbitrarily | Look at probability distribution first |
| One campaign per customer | Implement suppression rules |
| Static risk scores | Re-score monthly — risk changes over time |
| Reporting AUC to executives | Translate to business metrics — ROI, customers saved |
| Skipping LR baseline | Always start simple — complex models rarely justified |

---

## Quick Reference — Full Pipeline
```python
# 1. Load and clean
df = pd.read_sql('SELECT * FROM table', engine)
df['col'] = pd.to_numeric(df['col'].str.strip(), errors='coerce').fillna(0)
df['target'] = df['target'].map({'Yes': 1, 'No': 0})

# 2. Feature engineering
df['new_feature'] = df['a'] / df['b']
df = df.drop(['id', 'redundant_col'], axis=1)

# 3. Separate X and y
X = df.drop('target', axis=1)
y = df['target']

# 4. Encode and scale
X_encoded = pd.get_dummies(X, drop_first=True)
scaler = StandardScaler()
X_scaled = X_encoded.copy()
X_scaled[numeric_cols] = scaler.fit_transform(X_scaled[numeric_cols])

# 5. Split
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2,
    random_state=42, stratify=y
)

# 6. Train
lr_model = LogisticRegression(random_state=42,
           max_iter=1000, class_weight='balanced')
lr_model.fit(X_train, y_train)

# 7. Evaluate
pred = lr_model.predict(X_test)
prob = lr_model.predict_proba(X_test)[:, 1]
print(classification_report(y_test, pred))
print(f"AUC: {roc_auc_score(y_test, prob):.4f}")

# 8. Score all customers
# Apply same pipeline to full dataset
# Use original scaler — never refit
prob_all = lr_model.predict_proba(X_all_scaled)[:, 1]

# 9. Build scorecard
scorecard['risk_tier'] = scorecard['churn_probability'].apply(
    assign_risk_tier
)
scorecard.to_csv('outputs/churn_risk_scorecard.csv', index=False)
```

---

## Project 2 Improvements

Apply these patterns from day one on the next project:
```
✅ sklearn Pipeline — bundle scaler and model together
✅ XGBoost as primary model — industry standard
✅ GridSearchCV — systematic hyperparameter tuning
✅ SHAP values — explain individual predictions
✅ MLflow — track experiments and model versions
✅ Cross-validation — more robust than single train/test split
```
