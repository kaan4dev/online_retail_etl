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

