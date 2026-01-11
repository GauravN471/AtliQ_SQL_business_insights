/* 5.  Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost */

with cost_data as
(SELECT 
p.product_code ,
p.product ,
m.manufacturing_cost 
FROM gdb0041.dim_product p
join fact_manufacturing_cost m
ON p.product_code = m.product_code
)
SELECT *
FROM cost_data
WHERE manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM cost_data)
   OR manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM cost_data);