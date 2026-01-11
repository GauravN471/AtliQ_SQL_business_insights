/* 7.  Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month  .  This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month 
Year 
Gross sales Amount */ 

SELECT s.fiscal_year as year,
 MONTH(s.date) as Month,
 SUM(s.sold_quantity * g.gross_price) as Gross_sales_Amount
FROM gdb0041.fact_sales_monthly s
join fact_gross_price g
on  s.product_code = g.product_code
AND s.fiscal_year = g.fiscal_year
join dim_customer c
on c.customer_code = s.customer_code
where customer = "Atliq Exclusive"
group by Month, s.fiscal_year
order by Month, s.fiscal_year;