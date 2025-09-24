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



SELECT m.stock_code, n.description, SUM(m.quantity) as total_quantity FROM fact_sales AS m 
JOIN dim_product AS n 
ON m.stock_code = n.stock_code
WHERE description LIKE '%LIGHTS%'
GROUP BY m.stock_code, n.description
ORDER BY SUM(n.total_quantity) DESC
LIMIT 1;



SELECT m.customer_id, m.country, COUNT(DISTINCT(n.stock_code)) as distinct_products 
FROM dim_customer as m 
JOIN fact_sales AS n 
ON m.customer_id = n.customer_id
GROUP BY m.customer_id
ORDER BY COUNT(DISTINCT(n.stock_code)) DESC
LIMIT 1;



SELECT m.stock_code, m.description, (SUM(n.quantity)) AS total_quantity 
FROM dim_product AS m 
JOIN fact_sales AS n 
ON m.stock_code = n.stock_code
GROUP BY m.stock_code
ORDER BY total_quantity DESC
LIMIT 1
OFFSET 1;



SELECT m.stock_code, m.description,
(SELECT MAX((SUM(quantity))) FROM fact_sales) AS n
FROM dim_product AS m
WHERE SUM(m.quantity) < SUM(n.quantity)
LIMIT 1;



SELECT m.customer_id, m.country, SUM(n.quantity) AS total_quantity
FROM dim_customer AS m 
JOIN fact_sales as n
ON m.customer_id = n.customer_id
GROUP BY m.customer_id, m.country
HAVING SUM(n.quantity) > 1000



SELECT m.stock_code, n.description, SUM(m.revenue) AS total_revenue
FROM fact_sales AS m 
JOIN dim_product AS n 
ON m.stock_code = n.stock_code



SELECT * 
FROM fact_sales
WHERE revenue = (SELECT MAX(revenue) FROM fact_sales);



SELECT * FROM fact_sales 
WHERE revenue > (SELECT AVG(revenue) FROM fact_sales)



SELECT stock_code, SUM(revenue) AS total_revenue
FROM fact_sales
GROUP BY stock_code
HAVING SUM(revenue) = (
    SELECT MAX(total_rev)
    FROM (
        SELECT SUM(revenue) AS total_rev
        FROM fact_sales
        GROUP BY stock_code
    ) AS sub
);


SELECT customer_id, m.total_revenue 
FROM fact_sales
GROUP BY customer_id
HAVING AVG(total_revenue) > 
(SELECT AVG(total_revenue) FROM
(
    SELECT SUM(revenue) AS total_revenue 
    FROM fact_sales
    GROUP BY customer_id
) as m
)


SELECT customer_id, SUM(revenue) AS total_revenue
FROM fact_sales
GROUP BY customer_id
HAVING SUM(revenue) > (
    SELECT AVG(total_revenue) 
    FROM (
        SELECT SUM(revenue) AS total_revenue 
        FROM fact_sales
        GROUP BY customer_id
    ) AS sub
);



SELECT c.country, f.customer_id ,MAX(SUM(f.revenue))
(SELECT c.country, f.customer_id, SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_customer c 
ON f.customer_id = c.customer_id
GROUP BY c.country, f.customer_id;)



SELECT country, MAX(total_revenue) AS max_revenue
FROM (
    SELECT 
      c.country, 
      f.customer_id, 
      SUM(f.revenue) AS total_revenue
    FROM fact_sales f
    JOIN dim_customer c 
      ON f.customer_id = c.customer_id
    GROUP BY c.country, f.customer_id
) AS sub
GROUP BY country;



SELECT customer_id, distinct_products
(
    SELECT customer_id, Count(DISTINCT stock_code) as distinct_products FROM fact_sales
    GROUP BY customer_id, stock_code
) as m
WHERE distinct_products = 
(
    SELECT MAX(product_count)
    FROM
    (
        SELECT customer_id, COUNT(DISTINCT stock_code) AS product_count
        FROM fact_sales
        GROUP BY customer_id
    )
    as n
)
GROUP BY customer_id
























Soru 42 – Ortalama Günlük Gelirin Üstünde Kalan Günler

Her gün için toplam geliri (SUM(revenue)) bul.
Sadece günlük ortalamanın üstünde kalan günleri listele.
Sonuç: invoice_date, daily_revenue.
(İçte günlük ortalama hesaplayan bir subquery olacak.)