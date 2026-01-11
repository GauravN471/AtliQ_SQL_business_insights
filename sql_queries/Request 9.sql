/* 9.  Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_mln 
percentage */ 

WITH channel_sales AS (
SELECT c.channel,
SUM(s.sold_quantity * g.gross_price) as gross_sales 
FROM fact_sales_monthly s
join dim_customer c
on c.customer_code = s.customer_code
join fact_gross_price g 
on s.product_code = g.product_code
and s.fiscal_year = g.fiscal_year
where s.fiscal_year = 2021
group by channel
),
total as (
    SELECT SUM(gross_sales) AS total_sales
    FROM channel_sales
)
SELECT
    cs.channel,
    ROUND(cs.gross_sales / 1000000, 2) AS gross_sales_mln,
    ROUND(cs.gross_sales * 100.0 / t.total_sales, 2) AS percentage
FROM channel_sales cs
CROSS JOIN total t
ORDER BY percentage DESC;