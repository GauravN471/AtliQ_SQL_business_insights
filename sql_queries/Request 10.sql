/* 10.  Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these 
fields, 
division 
product_code */

WITH product_sales AS (
    SELECT
        p.division,
        s.product_code,
        SUM(s.sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly s
    JOIN dim_product p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY p.division, s.product_code
), 
ranked AS (
    SELECT
        division,
        product_code,
        total_sold_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY division
            ORDER BY total_sold_quantity DESC
        ) AS rn
    FROM product_sales
)
SELECT
    division,
    product_code,
    total_sold_quantity
FROM ranked
WHERE rn <= 3
ORDER BY division, total_sold_quantity DESC;