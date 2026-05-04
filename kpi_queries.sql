-- ============================================================
-- Financial KPI Dashboard — KPI Query Library
-- Author: Satyam Thakur
-- Description: Production-ready SQL queries for financial
--              KPI tracking, trend analysis & variance reporting
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- KPI 1: Monthly Revenue Summary
-- ─────────────────────────────────────────────────────────────
SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m')  AS fiscal_month,
    SUM(CASE WHEN tc.category_type = 'REVENUE' AND t.transaction_type = 'CREDIT'
             THEN t.amount ELSE 0 END)        AS total_revenue,
    SUM(CASE WHEN tc.category_type = 'COGS'   AND t.transaction_type = 'DEBIT'
             THEN t.amount ELSE 0 END)        AS total_cogs,
    SUM(CASE WHEN tc.category_type = 'EXPENSE' AND t.transaction_type = 'DEBIT'
             THEN t.amount ELSE 0 END)        AS total_expenses
FROM transactions t
JOIN accounts           a  ON t.account_id    = a.account_id
JOIN transaction_categories tc ON a.category_id = tc.category_id
GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
ORDER BY fiscal_month;


-- ─────────────────────────────────────────────────────────────
-- KPI 2: Gross Margin % by Month
-- ─────────────────────────────────────────────────────────────
WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS fiscal_month,
        SUM(CASE WHEN tc.category_type = 'REVENUE' AND t.transaction_type = 'CREDIT'
                 THEN t.amount ELSE 0 END)       AS revenue,
        SUM(CASE WHEN tc.category_type = 'COGS'   AND t.transaction_type = 'DEBIT'
                 THEN t.amount ELSE 0 END)       AS cogs
    FROM transactions t
    JOIN accounts a             ON t.account_id  = a.account_id
    JOIN transaction_categories tc ON a.category_id = tc.category_id
    GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
)
SELECT
    fiscal_month,
    revenue,
    cogs,
    (revenue - cogs)                            AS gross_profit,
    ROUND((revenue - cogs) / NULLIF(revenue, 0) * 100, 2) AS gross_margin_pct
FROM monthly_totals
ORDER BY fiscal_month;


-- ─────────────────────────────────────────────────────────────
-- KPI 3: Month-over-Month Revenue Growth (Window Function)
-- ─────────────────────────────────────────────────────────────
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS fiscal_month,
        SUM(t.amount)                            AS revenue
    FROM transactions t
    JOIN accounts a             ON t.account_id  = a.account_id
    JOIN transaction_categories tc ON a.category_id = tc.category_id
    WHERE tc.category_type = 'REVENUE'
      AND t.transaction_type = 'CREDIT'
    GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
)
SELECT
    fiscal_month,
    revenue,
    LAG(revenue) OVER (ORDER BY fiscal_month)   AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY fiscal_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY fiscal_month), 0) * 100
    , 2)                                        AS mom_growth_pct
FROM monthly_revenue
ORDER BY fiscal_month;


-- ─────────────────────────────────────────────────────────────
-- KPI 4: Budget vs Actual Variance by Department
-- ─────────────────────────────────────────────────────────────
WITH actuals AS (
    SELECT
        t.department_id,
        YEAR(t.transaction_date)    AS fiscal_year,
        MONTH(t.transaction_date)   AS fiscal_month,
        t.account_id,
        SUM(t.amount)               AS actual_amount
    FROM transactions t
    WHERE t.transaction_type = 'DEBIT'
    GROUP BY t.department_id, YEAR(t.transaction_date),
             MONTH(t.transaction_date), t.account_id
)
SELECT
    d.department_name,
    b.fiscal_year,
    b.fiscal_month,
    a.account_name,
    COALESCE(ac.actual_amount, 0)               AS actual,
    b.budget_amount                             AS budget,
    COALESCE(ac.actual_amount, 0) - b.budget_amount AS variance,
    ROUND(
        (COALESCE(ac.actual_amount, 0) - b.budget_amount)
        / NULLIF(b.budget_amount, 0) * 100
    , 2)                                        AS variance_pct,
    CASE
        WHEN COALESCE(ac.actual_amount, 0) > b.budget_amount * 1.1 THEN '🔴 Over Budget'
        WHEN COALESCE(ac.actual_amount, 0) > b.budget_amount       THEN '🟡 Slightly Over'
        ELSE '🟢 On Track'
    END                                         AS budget_status
FROM budgets b
JOIN departments d ON b.department_id = d.department_id
JOIN accounts    a ON b.account_id    = a.account_id
LEFT JOIN actuals ac
    ON ac.department_id = b.department_id
   AND ac.account_id    = b.account_id
   AND ac.fiscal_year   = b.fiscal_year
   AND ac.fiscal_month  = b.fiscal_month
ORDER BY b.fiscal_year, b.fiscal_month, d.department_name;


-- ─────────────────────────────────────────────────────────────
-- KPI 5: Year-over-Year Revenue Comparison (YoY)
-- ─────────────────────────────────────────────────────────────
WITH yearly AS (
    SELECT
        YEAR(t.transaction_date)  AS fiscal_year,
        SUM(t.amount)             AS annual_revenue
    FROM transactions t
    JOIN accounts a             ON t.account_id  = a.account_id
    JOIN transaction_categories tc ON a.category_id = tc.category_id
    WHERE tc.category_type    = 'REVENUE'
      AND t.transaction_type  = 'CREDIT'
    GROUP BY YEAR(t.transaction_date)
)
SELECT
    fiscal_year,
    annual_revenue,
    LAG(annual_revenue) OVER (ORDER BY fiscal_year) AS prior_year_revenue,
    ROUND(
        (annual_revenue - LAG(annual_revenue) OVER (ORDER BY fiscal_year))
        / NULLIF(LAG(annual_revenue) OVER (ORDER BY fiscal_year), 0) * 100
    , 2)                                            AS yoy_growth_pct
FROM yearly
ORDER BY fiscal_year;


-- ─────────────────────────────────────────────────────────────
-- KPI 6: Expense Ratio by Department (Ranked)
-- ─────────────────────────────────────────────────────────────
WITH dept_expenses AS (
    SELECT
        d.department_name,
        SUM(CASE WHEN tc.category_type = 'EXPENSE' THEN t.amount ELSE 0 END) AS total_expenses
    FROM transactions t
    JOIN departments            d  ON t.department_id = d.department_id
    JOIN accounts               a  ON t.account_id    = a.account_id
    JOIN transaction_categories tc ON a.category_id   = tc.category_id
    WHERE t.transaction_type = 'DEBIT'
    GROUP BY d.department_name
),
total_revenue AS (
    SELECT SUM(t.amount) AS revenue
    FROM transactions t
    JOIN accounts a             ON t.account_id  = a.account_id
    JOIN transaction_categories tc ON a.category_id = tc.category_id
    WHERE tc.category_type   = 'REVENUE'
      AND t.transaction_type = 'CREDIT'
)
SELECT
    de.department_name,
    de.total_expenses,
    ROUND(de.total_expenses / NULLIF(tr.revenue, 0) * 100, 2) AS expense_ratio_pct,
    RANK() OVER (ORDER BY de.total_expenses DESC)              AS expense_rank
FROM dept_expenses de
CROSS JOIN total_revenue tr
ORDER BY expense_rank;
