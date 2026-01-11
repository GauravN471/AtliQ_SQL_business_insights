/*4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
The final output contains these fields, segment product_count_2020 
product_count_2021 difference */

WITH segment_year_products AS (
    SELECT
        p.segment,
        s.fiscal_year,
        COUNT(DISTINCT s.product_code) AS product_count
    FROM fact_sales_monthly s
    JOIN dim_product p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year IN (2020, 2021)
    GROUP BY p.segment, s.fiscal_year
),
pivoted AS (
    SELECT
        segment,
        MAX(CASE WHEN fiscal_year = 2020 THEN product_count END) AS product_count_2020,
        MAX(CASE WHEN fiscal_year = 2021 THEN product_count END) AS product_count_2021
    FROM segment_year_products
    GROUP BY segment
)
SELECT
    segment,
    product_count_2020,
    product_count_2021,
    product_count_2021 - product_count_2020 AS difference
FROM pivoted
ORDER BY difference DESC;