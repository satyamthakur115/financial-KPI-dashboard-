# 🏦 Financial KPI Dashboard

[![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![Excel](https://img.shields.io/badge/Excel-217346?style=flat-square&logo=microsoftexcel&logoColor=white)]()
[![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat-square&logo=powerbi&logoColor=black)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Capstone project — Conestoga College, Financial Analysis Diploma (2025)**  
> An end-to-end financial data pipeline: normalized SQL schema → KPI queries → automated Python reporting → Power BI dashboards.

---

## 📌 Project Overview

This project simulates a real-world financial analytics workflow for a mid-sized business. It covers the full data lifecycle from raw transaction ingestion to executive-ready dashboards.

**Key outcomes:**
- Identified a **12% cost reduction** opportunity through department-level variance analysis
- Reduced manual reporting time from **3 hours to under 10 minutes** via Python automation
- Built reusable SQL KPI library covering revenue, margin, expense, and cash flow metrics

---

## 📊 Key Findings**
- Identified 12% cost reduction opportunity by analyzing department-level budget variance, with the largest overspending in operations and logistics
- Discovered declining gross margin trend (−4.2%) over 6 months, driven by rising COGS without proportional revenue growth
- Found that top 20% of products contributed ~65% of total revenue, highlighting strong product concentration risk
- Detected seasonal revenue patterns, with peak performance in Q4 and consistent dips in Q2
- Revealed high expense ratio (>78%) in underperforming departments, indicating inefficiency and potential restructuring areas
- Automated reporting reduced manual effort by ~95% (3 hours → under 10 minutes), enabling faster decision-making

---

## 🗂️ Project Structure

```
financial-KPI-dashboard/
│
├── sql/
│   ├── schema.sql              # Database schema — tables, indexes, constraints
│   └── kpi_queries.sql         # All KPI queries (revenue, margin, YoY, variance)
│
├── python/
│   ├── data_generator.py       # Generates realistic sample financial data
│   └── report_generator.py     # Automates Excel report creation from SQL output
│
├── data/
│   └── sample_data.csv         # Sample dataset (anonymized)
│
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Database | MySQL / SQL Server |
| Data Processing | Python 3.10+, Pandas, NumPy |
| Reporting | OpenPyXL (Excel automation) |
| Visualization | Power BI, Excel Pivot Tables |
| Version Control | Git / GitHub |

---

## 🗄️ Database Schema

The schema follows **3NF normalization** with four core tables:

```
departments ──< transactions >── accounts
                    │
               transaction_categories
```

See [`sql/schema.sql`](sql/schema.sql) for full DDL with indexes and constraints.

---

## 📊 KPI Definitions

| KPI | Formula | Business Use |
|---|---|---|
| Gross Margin % | `(Revenue - COGS) / Revenue * 100` | Profitability tracking |
| MoM Revenue Growth | `(Current - Previous) / Previous * 100` | Trend analysis |
| Budget Variance | `Actual - Budget` | Cost control |
| YoY Comparison | Window function over 12-month lag | Executive reporting |
| Expense Ratio | `Total Expenses / Total Revenue * 100` | Efficiency monitoring |

---

## ⚡ Quick Start

### 1. Clone the repo
```bash
git clone https://github.com/satyamthakur115/financial-KPI-dashboard-.git
cd financial-KPI-dashboard-
```

### 2. Set up the database
```bash
# Run schema creation
mysql -u root -p < sql/schema.sql
```

### 3. Generate sample data
```bash
pip install pandas numpy faker openpyxl
python python/data_generator.py
```

### 4. Run automated reports
```bash
python python/report_generator.py
# Output: reports/Financial_KPI_Report_YYYY-MM.xlsx
```

---

## 📈 Sample Output

The automated report includes:
- **Revenue Trend** — monthly breakdown with MoM growth %
- **Department P&L** — actual vs budget variance per department  
- **Top/Bottom Performers** — ranked product/category analysis
- **Cash Flow Summary** — rolling 3-month projection

---

## 🔍 Key SQL Techniques Used

- **CTEs** for multi-step KPI calculations
- **Window functions** (`LAG`, `LEAD`, `RANK`) for trend analysis
- **Aggregate + GROUP BY ROLLUP** for hierarchical reporting
- **Indexed views** for dashboard query optimization
- **Stored procedures** for parameterized report generation

---

## 👤 Author

**Satyam Thakur** — Data Analyst | Database Administrator  
📧 satyamthakur115@gmail.com | [LinkedIn](https://www.linkedin.com/in/satyam-thakur-94a4231b9/) | [GitHub](https://github.com/satyamthakur115)

