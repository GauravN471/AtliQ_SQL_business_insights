/*3.  Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 
2 fields, 
segment 
product_count */

SELECT segment ,
count(product_code) as num_of_product 
FROM gdb0041.dim_product
group by segment
order by num_of_product desc;