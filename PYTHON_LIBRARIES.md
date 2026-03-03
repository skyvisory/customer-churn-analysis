# Python Libraries Reference

Quick reference for Python libraries used in data analysis,
RevOps, and strategy projects.

---

## Installation

Install everything in one command:
```bash
python -m pip install pandas numpy matplotlib seaborn scikit-learn psycopg2-binary sqlalchemy jupyter ipykernel python-dotenv
```

Verify everything installed:
```bash
python -c "import pandas, numpy, matplotlib, seaborn, sklearn, psycopg2, sqlalchemy; print('All good')"
```

---

## Core Libraries

### Data Manipulation
| Library | Install | Import | What it does |
|---|---|---|---|
| `pandas` | `pip install pandas` | `import pandas as pd` | DataFrames — load, clean, transform, analyse tabular data |
| `numpy` | `pip install numpy` | `import numpy as np` | Numerical arrays and math — foundation for pandas and sklearn |

### Visualisation
| Library | Install | Import | What it does |
|---|---|---|---|
| `matplotlib` | `pip install matplotlib` | `import matplotlib.pyplot as plt` | Base charting — bar, line, scatter, histogram |
| `seaborn` | `pip install seaborn` | `import seaborn as sns` | Statistical charts — heatmaps, distributions, pair plots |
| `plotly` | `pip install plotly` | `import plotly.express as px` | Interactive charts — hover, zoom, drill down |

### Machine Learning
| Library | Install | Import | What it does |
|---|---|---|---|
| `scikit-learn` | `pip install scikit-learn` | `from sklearn.xxx import xxx` | ML models, feature engineering, model evaluation |
| `xgboost` | `pip install xgboost` | `import xgboost as xgb` | Gradient boosting — often beats random forest |
| `shap` | `pip install shap` | `import shap` | Explains ML model predictions in plain English |

### Database Connections
| Library | Install | Import | What it does |
|---|---|---|---|
| `psycopg2-binary` | `pip install psycopg2-binary` | `import psycopg2` | PostgreSQL connector |
| `sqlalchemy` | `pip install sqlalchemy` | `from sqlalchemy import create_engine` | Clean database connections for pandas |
| `duckdb` | `pip install duckdb` | `import duckdb` | Run SQL directly on DataFrames and CSV files |

### Notebooks
| Library | Install | Import | What it does |
|---|---|---|---|
| `jupyter` | `pip install jupyter` | — | Runs .ipynb notebook files |
| `ipykernel` | `pip install ipykernel` | — | Links Python to Jupyter in VS Code |

---

## Project Specific Installs

### This project (Customer Churn Analysis)
```bash
python -m pip install pandas numpy matplotlib seaborn scikit-learn psycopg2-binary sqlalchemy jupyter ipykernel
```

### Future Project 2 (Sales Pipeline Dashboard)
```bash
python -m pip install pandas numpy matplotlib seaborn streamlit duckdb faker sqlalchemy
```

### Future Project 3 (Market Intelligence Analyzer)
```bash
python -m pip install pandas numpy matplotlib seaborn spacy nltk wordcloud requests
python -m spacy download en_core_web_sm
```

### Future Project 4 (SaaS Unit Economics)
```bash
python -m pip install pandas numpy matplotlib seaborn plotly sqlalchemy jupyter ipykernel
```

### Future Project 5 (AI BI Tool)
```bash
python -m pip install pandas streamlit anthropic openai python-dotenv
```

---

## Most Used Imports

Copy this block at the top of every notebook:
```python
# Data
import pandas as pd
import numpy as np

# Visualisation
import matplotlib.pyplot as plt
import seaborn as sns

# Database
from sqlalchemy import create_engine

# ML
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix

# Settings
import warnings
warnings.filterwarnings('ignore')
%matplotlib inline
```

---

## Quick Reference

**Which library for which task:**

| Task | Library |
|---|---|
| Load a CSV | `pandas` |
| Connect to PostgreSQL | `psycopg2` + `sqlalchemy` |
| Run SQL on a DataFrame | `duckdb` |
| Clean and transform data | `pandas` |
| Bar / line / scatter chart | `matplotlib` |
| Heatmap / distribution | `seaborn` |
| Interactive chart | `plotly` |
| Train a ML model | `scikit-learn` |
| Build a web dashboard | `streamlit` |
| NLP / text analysis | `spacy` or `nltk` |
| Generate fake data | `faker` |
| Call AI APIs | `anthropic` or `openai` |
| Explain ML predictions | `shap` |
```
