/*
-----------------------------------------------------------------------------------------------------------------------------
Ranking Analysis -rank dimensions by measures to identify top performers or laggards

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
-----------------------------------------------------------------------------------------------------------------------------
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

--using window function
SELECT *
FROM(
	SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	GROUP BY p.product_name
	) AS ranked_products
WHERE rank_products <=5;


-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Find the Top 10 customers who have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
GROUP BY  
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the fewest order placed
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
GROUP BY  
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_orders; 
