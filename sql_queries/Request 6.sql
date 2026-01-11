/* 6.  Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage */ 

SELECT pr.customer_code,
c.customer,
 ROUND(AVG(pr.pre_invoice_discount_pct), 2) AS average_discount_percentage
 FROM gdb0041.fact_pre_invoice_deductions pr
 join dim_customer c 
 on c.customer_code = pr.customer_code
 where fiscal_year = 2021 and c.market ="India"
 GROUP BY pr.customer_code, c.customer
 ORDER BY average_discount_percentage DESC
 limit 5;