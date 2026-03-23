# 🔍 AtliQ Hardwares — SQL Business Insights | FY2020–2021

![MySQL](https://img.shields.io/badge/MySQL-Advanced-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CTEs%20%7C%20Window%20Functions%20%7C%20Joins-orange?style=for-the-badge)
![PowerPoint](https://img.shields.io/badge/Presentation-Executive%20Deck-B7472A?style=for-the-badge&logo=microsoft-powerpoint&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)

> **"Translated 1M+ rows of raw transactional data into 10 executive-ready business insights — covering channel strategy, margin risk, seasonal demand, and product portfolio decisions."**

---

## 🎯 Executive Summary

AtliQ Hardwares' senior leadership needed data-backed answers to 10 critical business questions spanning product performance, customer profitability, channel revenue, and demand seasonality — but had no analytical layer on top of their transactional database. I queried the MySQL database end-to-end using CTEs, window functions, multi-table JOINs, and aggregations to deliver a structured set of insights presented in an executive PowerPoint deck.

---

## 🛠 Tech Stack

| Tool | Purpose |
|---|---|
| **MySQL** | Primary query engine — all analysis performed in SQL |
| **CTEs** (Common Table Expressions) | Breaking complex logic into readable, reusable steps |
| **Window Functions** | RANK(), DENSE_RANK(), OVER(PARTITION BY) for rankings |
| **Multi-table JOINs** | Joining fact and dimension tables across the star schema |
| **Aggregations** | SUM, COUNT, AVG, GROUP BY for KPI computation |
| **Subqueries** | Nested logic for cost comparisons and filtering |
| **PowerPoint** | Executive presentation of findings to stakeholders |

---

## 🗄 Database Schema Overview
```
dim_customer      → customer_code, customer, market, platform, channel
dim_product       → product_code, division, segment, category, product, variant
dim_market        → market, sub_zone, region
fact_sales_monthly → date, product_code, customer_code, sold_quantity
fact_manufacturing_cost → product_code, cost_year, manufacturing_cost
fact_pre_invoice_deductions → customer_code, fiscal_year, pre_invoice_discount_pct
fact_post_invoice_deductions → customer_code, product_code, date, discount_pct
```

**Relationships:** All fact tables join to dimension tables via `customer_code` and `product_code`.
**Fiscal Year:** AtliQ operates Sept–Aug (non-calendar year — handled in all queries).

---

## ❓ The 10 Business Questions Solved

| # | Business Question | SQL Techniques Used |
|---|---|---|
| 1 | Which markets does Atliq Exclusive operate in (APAC)? | WHERE + DISTINCT |
| 2 | What was the % increase in unique products from 2020 to 2021? | CTEs + DIVIDE logic |
| 3 | Which segments had the most unique product counts? | GROUP BY + COUNT DISTINCT |
| 4 | Which segment saw the biggest product increase 2020 vs 2021? | CTEs + JOIN + difference calc |
| 5 | Which products have highest and lowest manufacturing cost? | JOIN + ORDER BY + LIMIT |
| 6 | Which customers receive the highest average pre-invoice discounts? | JOIN + AVG + GROUP BY |
| 7 | What is the monthly Gross Sales trend for Atliq Exclusive? | JOIN + SUM + fiscal month logic |
| 8 | Which quarter of FY2020 had the highest total sold quantity? | CASE WHEN fiscal quarter + SUM |
| 9 | Which channel contributed most to FY2021 Gross Sales (and %)? | CTEs + SUM + DIVIDE for % share |
| 10 | Which are the top 3 products by sold quantity in each division? | Window Function: RANK() OVER(PARTITION BY) |

---

## 🧹 Data Approach & Query Design

**1. Fiscal year normalisation**
AtliQ's fiscal year starts in September. Every time-based query required a custom fiscal month mapping using `CASE WHEN MONTH(date) >= 9 THEN YEAR(date)+1 ELSE YEAR(date) END` to avoid incorrect year groupings with standard calendar logic.

**2. Percentage calculations via CTEs**
Rather than using nested subqueries (which become unreadable), all percentage and ratio calculations — such as unique product growth % and channel revenue share % — were structured as multi-step CTEs for clarity and auditability.

**3. Top-N ranking with window functions**
For the division-wise top 3 products question, `RANK() OVER (PARTITION BY division ORDER BY sold_quantity DESC)` was used instead of subqueries — producing cleaner, more scalable code that works correctly even when quantities are tied.

**4. Multi-table cost joins**
Manufacturing cost analysis required joining `fact_manufacturing_cost` to `dim_product` and `dim_customer` across different granularities — handled with careful JOIN conditions to avoid fan-out (row multiplication errors).

---

## 💡 Business Insights — The "So What?"

- **Identified that the Retailer channel drives ~73% of FY2021 Gross Sales** — flagging a dangerous revenue concentration risk. This finding supports a strategic recommendation to invest in Direct and Distributor channel development to reduce single-channel dependency.

- **Discovered Q1 (Sept–Nov) as the lowest demand quarter and Q4 as the peak**, with Q4 accounting for ~41% of annual sold quantity — enabling the supply chain team to build a seasonally-adjusted procurement and stocking plan rather than flat monthly targets.

- **Found that select customers receive pre-invoice discount percentages significantly above the portfolio average** — when cross-referenced with their Gross Sales contribution, these accounts show the highest margin erosion risk, giving the finance team a direct input for discount policy renegotiation.

---

## 📋 Business Recommendations

1. **Channel Diversification** — With ~73% revenue dependence on the Retailer channel, AtliQ should set a 3-year target to grow Direct and Distributor share to reduce concentration risk.
2. **Seasonal Inventory Strategy** — Q4's disproportionate demand (~41%) requires a forward-buying plan starting Q2 to avoid stockouts during the peak selling season.
3. **Discount Audit** — Customers with above-average pre-invoice discounts and below-average revenue contribution should be flagged for a commercial review — recovering even 1–2% discount points across these accounts would materially improve Net Sales.
4. **Product Portfolio Focus** — Segments with the highest SKU growth (2020→2021) should be monitored for cannibalization; adding SKUs without corresponding revenue growth signals assortment complexity without return.

---

## 💻 Sample SQL — See the Code in Action

**Question 9: Which channel drove the most Gross Sales in FY2021? (with % share)**
```sql
WITH channel_sales AS (
    SELECT
        c.channel,
        ROUND(SUM(s.sold_quantity * g.gross_price) / 1000000, 2) AS gross_sales_mln
    FROM fact_sales_monthly s
    JOIN dim_customer c        ON s.customer_code = c.customer_code
    JOIN fact_gross_price g    ON s.product_code = g.product_code
                               AND s.fiscal_year = g.fiscal_year
    WHERE s.fiscal_year = 2021
    GROUP BY c.channel
),
total AS (
    SELECT SUM(gross_sales_mln) AS total_sales FROM channel_sales
)
SELECT
    cs.channel,
    cs.gross_sales_mln,
    ROUND(cs.gross_sales_mln / t.total_sales * 100, 2) AS pct_share
FROM channel_sales cs, total t
ORDER BY cs.gross_sales_mln DESC;
```

**Question 10: Top 3 products by sold quantity per division**
```sql
WITH ranked_products AS (
    SELECT
        p.division,
        p.product_code,
        p.product,
        SUM(s.sold_quantity) AS total_sold_qty,
        RANK() OVER (
            PARTITION BY p.division
            ORDER BY SUM(s.sold_quantity) DESC
        ) AS rnk
    FROM fact_sales_monthly s
    JOIN dim_product p ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.division, p.product_code, p.product
)
SELECT division, product_code, product, total_sold_qty, rnk
FROM ranked_products
WHERE rnk <= 3;
```

---

## 🗂 Repository Structure
```
AtliQ_SQL_business_insights/
├── README.md                  ← This file
├── sql_queries/               ← All 10 SQL scripts (one per business question)
└── presentation/              ← Executive stakeholder presentation (PDF/PPT)
```

> 📂 Each file in `sql_queries/` is named by question number and topic  
> e.g. `01_markets_atliq_exclusive.sql`, `10_top3_products_by_division.sql`

---

## 👤 Author

**Gaurav Nikam** — Data Analyst | SQL · Power BI · Excel · Bloomberg Terminal
📧 gauravnikam471@gmail.com
🔗 [LinkedIn](https://www.linkedin.com/in/-471-gaurav-nikam)
