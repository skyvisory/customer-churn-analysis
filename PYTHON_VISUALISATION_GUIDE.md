# Python Visualisation Guide
A reference guide for producing quality charts in Python.
Built from the Customer Churn Analysis project.

---

## Core Libraries
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Always set style at the top of your notebook
sns.set_theme(style="whitegrid")
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['font.size'] = 12
plt.rcParams['axes.titlesize'] = 14
plt.rcParams['axes.titleweight'] = 'bold'
```

---

## The Universal Chart Template

Every chart you build should follow this structure:
```python
# 1. Prepare data
data = df.groupby('category')['metric'].agg(...)
data = data.sort_values('metric', ascending=False)

# 2. Create canvas
fig, ax = plt.subplots(figsize=(10, 6))

# 3. Draw chart
bars = ax.bar(data.index, data['metric'], color=colors)

# 4. Add labels
for bar, value in zip(bars, data['metric']):
    ax.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 0.5,
        f'{value:.1f}%',
        ha='center', va='bottom',
        fontweight='bold', fontsize=12
    )

# 5. Titles and axis labels
ax.set_title('Insight — not just description', pad=15)
ax.set_xlabel('Category')
ax.set_ylabel('Metric')

# 6. Annotate key insight
ax.annotate(
    'Key finding here',
    xy=(x_point, y_point),
    xytext=(x_text, y_text),
    fontsize=10,
    color='#e74c3c',
    arrowprops=dict(arrowstyle='->', color='#e74c3c')
)

# 7. Save and show
plt.tight_layout()
plt.savefig('../outputs/figures/chart_name.png',
            dpi=150, bbox_inches='tight')
plt.show()
```

---

## Chart Type Selection

| Situation | Chart type | Code |
|---|---|---|
| Compare categories | Bar chart | `ax.bar()` |
| Show composition | Stacked bar | `ax.bar(bottom=...)` |
| Part of whole | Pie chart | `ax.pie()` |
| Trend over time | Line chart | `ax.plot()` |
| Two variables | Scatter plot | `ax.scatter()` |
| Distribution | Histogram | `ax.hist()` |
| Correlation matrix | Heatmap | `sns.heatmap()` |
| Distribution by category | Box plot | `sns.boxplot()` |
| Distribution shape | Violin plot | `sns.violinplot()` |
| Pairwise relationships | Pair plot | `sns.pairplot()` |

---

## Canvas Setup

### Single chart
```python
fig, ax = plt.subplots(figsize=(10, 6))
```

### Two charts side by side
```python
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
# axes[0] = left chart
# axes[1] = right chart
```

### Two charts stacked vertically
```python
fig, axes = plt.subplots(2, 1, figsize=(10, 12))
# axes[0] = top chart
# axes[1] = bottom chart
```

### 2x2 grid
```python
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
# axes[0][0] = top left
# axes[0][1] = top right
# axes[1][0] = bottom left
# axes[1][1] = bottom right
```

---

## Colour Principles

### Use colour to encode meaning — not just aesthetics
```python
# Traffic light — urgency encoding
RED    = '#e74c3c'  # high risk / bad
ORANGE = '#e67e22'  # medium risk / warning
YELLOW = '#f1c40f'  # low-medium risk
GREEN  = '#2ecc71'  # low risk / good
DARK_GREEN = '#27ae60'  # very low risk / excellent

# Neutral
BLUE  = '#3498db'  # informational
GRAY  = '#95a5a6'  # secondary / muted
WHITE = '#ffffff'  # background / separator
```

### Churn-specific palette
```python
CHURN_COLORS = {
    'Churned':  '#e74c3c',  # red
    'Retained': '#2ecc71'   # green
}
```

### Consistent colours across all charts
Define colours once at the top of your notebook — never hardcode hex values in individual charts.

### When to use which palette
| Situation | Palette |
|---|---|
| Binary (yes/no, churned/retained) | Red + Green |
| Ranked categories | Red → Orange → Yellow → Green |
| Neutral categories | `sns.color_palette('Set2')` |
| Sequential (low to high) | `sns.color_palette('Blues')` |
| Diverging (negative to positive) | `sns.color_palette('RdYlGn')` |

---

## Data Preparation Patterns

### Always sort by the metric — not alphabetically
```python
# Good — data driven order
data = data.sort_values('churn_rate', ascending=False)

# Bad — alphabetical order hides the story
data = data.reindex(['Category A', 'Category B', 'Category C'])
```

### Exception — keep natural order for time and lifecycle
```python
# Tenure groups have a natural lifecycle order
# Keep chronological — don't sort by churn rate
tenure_order = ['0-12 months', '13-24 months',
                '25-48 months', '48+ months']
```

### Dynamic category order
```python
# Always extract order from sorted data
category_order = data.sort_values(
    'metric', ascending=False
).index.tolist()
```

---

## Labelling Best Practices

### Bar value labels
```python
# On top of each bar
for bar, value in zip(bars, values):
    ax.text(
        bar.get_x() + bar.get_width() / 2,  # x centre
        bar.get_height() + 0.5,              # just above bar
        f'{value:.1f}%',                     # formatted value
        ha='center', va='bottom',
        fontweight='bold', fontsize=12
    )
```

### Automatic bar labels (simpler)
```python
# Let matplotlib do it automatically
for container in ax.containers:
    ax.bar_label(container, padding=3, fontsize=10)
```

### Y-axis dollar formatting
```python
ax.yaxis.set_major_formatter(
    plt.FuncFormatter(lambda x, p: f'${x:,.0f}')
)
```

### Y-axis percentage formatting
```python
ax.yaxis.set_major_formatter(
    plt.FuncFormatter(lambda x, p: f'{x:.0f}%')
)
```

---

## Annotations

### Arrow pointing to insight
```python
ax.annotate(
    'Key insight text',
    xy=(x_target, y_target),       # where arrow points TO
    xytext=(x_label, y_label),     # where text sits
    fontsize=10,
    color='#e74c3c',
    arrowprops=dict(arrowstyle='->', color='#e74c3c')
)
```

### Floating text box — no arrow
```python
ax.text(
    x, y,
    'Summary text here',
    ha='center', va='bottom',
    fontweight='bold', fontsize=11,
    color='#e74c3c',
    bbox=dict(
        boxstyle='round,pad=0.4',
        facecolor='#fdf0ee',
        edgecolor='#e74c3c',
        linewidth=1.5
    )
)
```

### Vertical reference line
```python
ax.axvline(x=1.5, color='gray',
           linestyle='--', linewidth=1.5, alpha=0.7)
```

### Horizontal reference line
```python
ax.axhline(y=benchmark_value, color='orange',
           linestyle='--', linewidth=1.5,
           label='Industry benchmark')
```

---

## Titles

### Single chart title
```python
ax.set_title('The Insight — not just the topic', pad=15)
```

### Super title across multiple panels
```python
plt.suptitle(
    'The Key Finding Stated Clearly',
    fontsize=14, fontweight='bold', y=1.02
)
```

### Title writing principle
```python
# Bad title — describes what not what it means
ax.set_title('Churn Rate by Contract Type')

# Good title — states the insight
ax.set_title('Month-to-Month Customers Churn at 15x Two-Year Rate')
```

---

## Saving Charts
```python
plt.tight_layout()
plt.savefig('../outputs/figures/chart_name.png',
            dpi=150, bbox_inches='tight')
plt.show()
```

### Settings explained
| Setting | Value | Why |
|---|---|---|
| `dpi` | 150 | Sharp on screen, not oversized file |
| `bbox_inches='tight'` | 'tight' | Removes excess whitespace |
| `plt.tight_layout()` | — | Prevents panel overlap |

### Naming convention
```
01_overall_churn_rate.png
02_churn_by_contract.png
03_churn_by_tenure.png
```
Number prefix keeps files in logical order in the folder.

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---|---|
| Alphabetical bar order | Always sort by metric value |
| No value labels on bars | Add text labels to every bar |
| Generic title ("Churn by X") | State the insight in the title |
| Hardcoded colours everywhere | Define palette once at top |
| No annotation on key finding | Always highlight the main insight |
| Missing axis labels | Always set xlabel and ylabel |
| Chart cut off when saving | Use bbox_inches='tight' |
| Too many colours | Max 4-5 colours per chart |
| Pie chart with many slices | Use bar chart if more than 5 categories |
| Y-axis not starting at 0 | Always start at 0 for bar charts |
| $ in chart titles | Use \\$ to escape — matplotlib treats $ as LaTeX math delimiter |

---

## Quick Reference — Most Used Commands
```python
# Canvas
fig, ax = plt.subplots(figsize=(10, 6))
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Chart types
ax.bar(x, y, color=colors, width=0.5, edgecolor='white')
ax.plot(x, y, color='blue', linewidth=2, marker='o')
ax.scatter(x, y, color='blue', alpha=0.6, s=50)
ax.pie(values, labels=labels, autopct='%1.1f%%')
sns.heatmap(corr_matrix, annot=True, cmap='RdYlGn')
sns.boxplot(data=df, x='category', y='metric')

# Labels
ax.set_title('Title', pad=15)
ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.legend()
ax.tick_params(axis='x', rotation=45)

# Reference lines
ax.axhline(y=value, linestyle='--', color='gray')
ax.axvline(x=value, linestyle='--', color='gray')

# Save
plt.tight_layout()
plt.savefig('path/filename.png', dpi=150, bbox_inches='tight')
plt.show()
```

---

## The 5 Questions Before Every Chart

1. **What business question does this answer?**
   If you can't state it — don't build the chart yet

2. **What chart type best shows this relationship?**
   Comparison → bar, trend → line, composition → pie/stacked

3. **What order should categories appear in?**
   Sort by metric unless there's a natural order

4. **What is the single most important insight?**
   Annotate it directly on the chart

5. **What does the title tell the reader to conclude?**
   State the finding — not just the topic
