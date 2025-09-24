SELECT strftime('%Y-%m', invoice_date) AS Month,
ROUND(SUM(revenue), 2) AS monthly_revenue
FROM fact_sales
Group By 1 
Order By 1;



SELECT p.description,
       SUM(f.quantity) AS total_quantity,
       ROUND(SUM(f.revenue), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.stock_code = p.stock_code
GROUP BY 1
ORDER BY total_quantity DESC
LIMIT 10;



SELECT c.customer_id, c.country,
       ROUND(SUM(f.revenue), 2) AS total_revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY total_revenue DESC
LIMIT 10;



SELECT m.stock_code, n.description, SUM(m.revenue) as total_revenue FROM fact_sales AS m
JOIN dim_product AS n
ON m.stock_code = n.stock_code
Group By m.stock_code, n.description
LIMIT 10;



SELECT m.country, SUM(n.revenue) as total_revenue FROM dim_customer AS m
JOIN fact_sales AS n
ON m.customer_id = n.customer_id
GROUP BY m.country, n.revenue
LIMIT 1
ORDER BY DESC;



SELECT m.stock_code, m.description, SUM(n.quantity) AS total_quantity FROM dim_product AS m
JOIN fact_sales AS n 
ON m.stock_code = n.stock_code
GROUP BY n.stock_code, m.description
ORDER BY n.quantity DESC
LIMIT 10;



SELECT m.customer_id, COUNT(n.invoice_no) as total_invoice_no FROM dim_customer AS m
JOIN m.fact_sales as n 
ON m.customer_id = n.customer_id
GROUP BY m.customer_id
ORDER BY total_invoice_no DESC
LIMIT 10;



SELECT customer_id, SUM(revenue) FROM fact_sales
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;



SELECT n.country, SUM(m.revenue) / COUNT(DISTINCT m.invoice_no) as average_revenue FROM fact_sales AS m
JOIN dim_customer AS n 
ON m.customer_id = n.customer_id
GROUP BY n.country;



SELECT m.description, SUM(n.quantity) FROM dim_product as m
JOIN fact_sales AS n
ON m.stock_code = n.stock_code
WHERE description LIKE '%CHRISTMAS%'
GROUP BY stock_code 
ORDER BY SUM(n.quantity) DESC
LIMIT 1;








