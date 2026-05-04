"""
Financial KPI Dashboard — Sample Data Generator
Author: Satyam Thakur
Description: Generates realistic financial transaction data
             and seeds it into the MySQL database.
"""

import random
import mysql.connector
from datetime import datetime, timedelta
from decimal import Decimal

# ─── Config ────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",
    "password": "your_password_here",   # update this
    "database": "financial_kpi_db"
}

DEPARTMENTS  = [1, 2, 3, 4, 5]    # matches schema seed data
ACCOUNTS     = [1, 2, 3, 4, 5, 6, 7, 8]
REVENUE_ACCTS = [1, 2]             # product & consulting revenue
COGS_ACCTS    = [3]
EXPENSE_ACCTS = [4, 5, 6, 7, 8]

START_DATE = datetime(2023, 1, 1)
END_DATE   = datetime(2024, 12, 31)
NUM_TRANSACTIONS = 2000


def random_date(start: datetime, end: datetime) -> str:
    delta = end - start
    random_days = random.randint(0, delta.days)
    return (start + timedelta(days=random_days)).strftime("%Y-%m-%d")


def generate_transaction() -> dict:
    """Generate a single realistic financial transaction."""
    tx_type   = random.choices(["REVENUE", "EXPENSE"], weights=[40, 60])[0]

    if tx_type == "REVENUE":
        account_id = random.choice(REVENUE_ACCTS)
        amount     = round(random.uniform(500, 25000), 2)
        tx_kind    = "CREDIT"
        desc       = random.choice([
            "Q1 product sale", "Consulting engagement", "Software license",
            "Service retainer", "Enterprise contract renewal"
        ])
    elif tx_type == "EXPENSE":
        account_id = random.choice(EXPENSE_ACCTS)
        amount     = round(random.uniform(200, 8000), 2)
        tx_kind    = "DEBIT"
        desc       = random.choice([
            "Monthly salary run", "Google Ads campaign", "Office rent",
            "SaaS subscription renewal", "Team travel reimbursement",
            "AWS infrastructure", "Software license renewal"
        ])
    else:  # COGS
        account_id = random.choice(COGS_ACCTS)
        amount     = round(random.uniform(300, 10000), 2)
        tx_kind    = "DEBIT"
        desc       = "Cost of goods sold — product batch"

    return {
        "transaction_date": random_date(START_DATE, END_DATE),
        "department_id":    random.choice(DEPARTMENTS),
        "account_id":       account_id,
        "description":      desc,
        "amount":           amount,
        "transaction_type": tx_kind,
        "reference_number": f"REF-{random.randint(10000, 99999)}"
    }


def seed_budgets(cursor) -> None:
    """Seed monthly budget targets for all departments."""
    print("Seeding budgets...")
    for dept_id in DEPARTMENTS:
        for account_id in EXPENSE_ACCTS:
            for month in range(1, 13):
                budget_amount = round(random.uniform(3000, 15000), 2)
                cursor.execute("""
                    INSERT IGNORE INTO budgets
                        (department_id, account_id, fiscal_year, fiscal_month, budget_amount)
                    VALUES (%s, %s, %s, %s, %s)
                """, (dept_id, account_id, 2024, month, budget_amount))
    print(f"  ✅ Budgets seeded for {len(DEPARTMENTS)} departments × 12 months")


def main():
    print("🚀 Financial KPI Data Generator")
    print("=" * 40)

    conn   = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    # Seed transactions
    print(f"Generating {NUM_TRANSACTIONS} transactions...")
    insert_sql = """
        INSERT INTO transactions
            (transaction_date, department_id, account_id,
             description, amount, transaction_type, reference_number)
        VALUES
            (%(transaction_date)s, %(department_id)s, %(account_id)s,
             %(description)s, %(amount)s, %(transaction_type)s, %(reference_number)s)
    """
    rows = [generate_transaction() for _ in range(NUM_TRANSACTIONS)]
    cursor.executemany(insert_sql, rows)
    print(f"  ✅ Inserted {NUM_TRANSACTIONS} transactions")

    seed_budgets(cursor)

    conn.commit()
    cursor.close()
    conn.close()
    print("\n✅ Database seeded successfully!")
    print("Run 'python report_generator.py' to generate your first report.")


if __name__ == "__main__":
    main()
