-- ============================================================
-- Financial KPI Dashboard — Database Schema
-- Author: Satyam Thakur
-- Description: Normalized schema for financial transaction
--              analysis and KPI reporting
-- ============================================================

-- ─── Drop existing tables (clean slate) ────────────────────
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS transaction_categories;
DROP TABLE IF EXISTS budgets;

-- ─── Departments ───────────────────────────────────────────
CREATE TABLE departments (
    department_id   INT           PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100)  NOT NULL,
    manager_name    VARCHAR(100),
    cost_center     VARCHAR(20)   UNIQUE NOT NULL,
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_departments_name ON departments(department_name);

-- ─── Transaction Categories ─────────────────────────────────
CREATE TABLE transaction_categories (
    category_id     INT           PRIMARY KEY AUTO_INCREMENT,
    category_name   VARCHAR(100)  NOT NULL,
    category_type   ENUM('REVENUE', 'EXPENSE', 'COGS', 'ASSET', 'LIABILITY') NOT NULL,
    parent_id       INT           NULL,  -- supports hierarchy
    FOREIGN KEY (parent_id) REFERENCES transaction_categories(category_id)
);

-- ─── Accounts (Chart of Accounts) ──────────────────────────
CREATE TABLE accounts (
    account_id      INT           PRIMARY KEY AUTO_INCREMENT,
    account_code    VARCHAR(20)   UNIQUE NOT NULL,
    account_name    VARCHAR(150)  NOT NULL,
    category_id     INT           NOT NULL,
    is_active       BOOLEAN       DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id)
);

CREATE INDEX idx_accounts_category ON accounts(category_id);
CREATE INDEX idx_accounts_code     ON accounts(account_code);

-- ─── Budgets ────────────────────────────────────────────────
CREATE TABLE budgets (
    budget_id       INT           PRIMARY KEY AUTO_INCREMENT,
    department_id   INT           NOT NULL,
    account_id      INT           NOT NULL,
    fiscal_year     INT           NOT NULL,
    fiscal_month    TINYINT       NOT NULL CHECK (fiscal_month BETWEEN 1 AND 12),
    budget_amount   DECIMAL(15,2) NOT NULL,
    created_at      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (account_id)    REFERENCES accounts(account_id),
    UNIQUE KEY uq_budget (department_id, account_id, fiscal_year, fiscal_month)
);

-- ─── Transactions ───────────────────────────────────────────
CREATE TABLE transactions (
    transaction_id      INT            PRIMARY KEY AUTO_INCREMENT,
    transaction_date    DATE           NOT NULL,
    department_id       INT            NOT NULL,
    account_id          INT            NOT NULL,
    description         VARCHAR(255),
    amount              DECIMAL(15,2)  NOT NULL,
    transaction_type    ENUM('DEBIT','CREDIT') NOT NULL,
    reference_number    VARCHAR(50),
    created_at          DATETIME       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (account_id)    REFERENCES accounts(account_id)
);

-- Performance indexes for KPI queries
CREATE INDEX idx_tx_date         ON transactions(transaction_date);
CREATE INDEX idx_tx_department   ON transactions(department_id);
CREATE INDEX idx_tx_account      ON transactions(account_id);
CREATE INDEX idx_tx_date_dept    ON transactions(transaction_date, department_id);
CREATE INDEX idx_tx_type_date    ON transactions(transaction_type, transaction_date);

-- ─── Sample seed data ───────────────────────────────────────
INSERT INTO departments (department_name, manager_name, cost_center) VALUES
    ('Sales',        'Rajiv Sharma',   'CC-001'),
    ('Operations',   'Priya Mehta',    'CC-002'),
    ('Marketing',    'David Kim',      'CC-003'),
    ('Finance',      'Sarah Johnson',  'CC-004'),
    ('IT',           'Alex Chen',      'CC-005');

INSERT INTO transaction_categories (category_name, category_type) VALUES
    ('Product Revenue',     'REVENUE'),
    ('Service Revenue',     'REVENUE'),
    ('Cost of Goods Sold',  'COGS'),
    ('Salaries & Wages',    'EXPENSE'),
    ('Marketing Spend',     'EXPENSE'),
    ('Office & Admin',      'EXPENSE'),
    ('Software & Tools',    'EXPENSE'),
    ('Travel & Expenses',   'EXPENSE');

INSERT INTO accounts (account_code, account_name, category_id) VALUES
    ('4001', 'Product Sales',          1),
    ('4002', 'Consulting Revenue',     2),
    ('5001', 'Direct COGS',            3),
    ('6001', 'Employee Salaries',      4),
    ('6002', 'Marketing Campaigns',    5),
    ('6003', 'Office Rent & Utilities',6),
    ('6004', 'SaaS Subscriptions',     7),
    ('6005', 'Business Travel',        8);
