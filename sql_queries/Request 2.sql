/* 2. What is the percentage of unique product increase in 2021 vs. 2020? The 
final output contains these fields, 
unique_products_2020 
unique_products_2021 
percentage_chg */

with product_counts AS(
SELECT
        fiscal_year,
        COUNT(DISTINCT product_code) AS unique_products
    FROM fact_sales_monthly
    WHERE fiscal_year IN (2020, 2021)
    GROUP BY fiscal_year
    ),
   yearly AS
   (SELECT
    MAX(CASE WHEN fiscal_year = 2020 THEN unique_products END) AS p2020,
    MAX(CASE WHEN fiscal_year = 2021 THEN unique_products END) AS p2021
    FROM product_counts
    )
    SELECT
    p2020 AS unique_products_2020,
    p2021 AS unique_products_2021,
    ROUND( (p2021 - p2020) * 100.0 / p2020 , 2 ) AS percentage_chg
FROM yearly;