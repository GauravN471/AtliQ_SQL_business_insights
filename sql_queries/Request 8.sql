/* 8.  In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity */

SELECT
QUARTER(date) AS quarter, 
sum(sold_quantity) as total_sold_quantity
FROM gdb0041.fact_sales_monthly
where fiscal_year = 2020
group by quarter
ORDER BY total_sold_quantity DESC;