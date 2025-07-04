/*
===============================================================================
Database Exploration 
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns and types for a specific table 
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-----------------------------------------------------------------------------------------------------------------------------
-- Dimensions Exploration
-----------------------------------------------------------------------------------------------------------------------------

-- Retrive the unique countries where customers are from
SELECT DISTINCT country 
FROM gold.dim_customers
ORDER BY country;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT category, subcategory, product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;

-----------------------------------------------------------------------------------------------------------------------------
-- Date Exploration
-----------------------------------------------------------------------------------------------------------------------------

-- Find the date of the first and last oder
-- How many years and months of sales are available
SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and the oldest customer based on birthdate
SELECT
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

-----------------------------------------------------------------------------------------------------------------------------
-- Measures Exploration - calculate aggregrated metrics for quick insights
-----------------------------------------------------------------------------------------------------------------------------

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales 
FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity 
FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price 
FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders 
FROM gold.fact_sales
SELECT COUNT(DISTINCT(order_number)) AS total_orders 
FROM gold.fact_sales; -- to get unique order as same order can be have different product

-- Find the total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT(customer_key)) AS total_customers FROM gold.fact_sales;


-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Orders' AS measure_name, COUNT(DISTINCT(order_number)) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total No.Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total No. Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers;

-----------------------------------------------------------------------------------------------------------------------------
--Magnitude Analysis - compares the measure values by dimensions for understanding data distribution across categories
-----------------------------------------------------------------------------------------------------------------------------

-- Find total customers by countries
SELECT 
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT 
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;


-- Find total products by category
SELECT 
category,
	COUNT(product_key) AS total_products
	FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average costs in each category?
SELECT 
category,
	AVG(cost) AS avg_cost
	FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
SELECT
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
GROUP BY  p.category
ORDER BY total_revenue DESC;

-- Find total revenue generated by each customer
SELECT
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

-- What is the distribution of sold items across countries?
SELECT
c.country,
	SUM(f.quantity) AS total_sold_items
	FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
GROUP BY  c.country
ORDER BY total_sold_items DESC;

-----------------------------------------------------------------------------------------------------------------------------
--Ranking Analysis -rank dimensions by measures to identify top performers or laggards
-----------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------
--Change-Over-Time -Track trends and identify seasonality in data
-----------------------------------------------------------------------------------------------------------------------------

--Analyse Sales Performance Over Time
SELECT 
    YEAR(order_date) as order_year,
    MONTH(order_date) as order_month,
    SUM(sales_amount) as total_Sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- DATETRUNC()
SELECT 
    DATETRUNC(month, order_date) as order_date,
    SUM(sales_amount) as total_Sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-----------------------------------------------------------------------------------------------------------------------------
-- Cumulative Analysis - Helps understand if the business is growing or declining over time
-----------------------------------------------------------------------------------------------------------------------------

-- Calculate the total sales per month
-- and the running total sales over time
-- and the moving average over time

SELECT
      order_date,
      total_sales,
      SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
      avg_price_per_month,
      AVG(avg_price_per_month) OVER (ORDER BY order_date) AS moving_average_price
FROM 
    (
      SELECT 
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price_per_month
      FROM gold.fact_sales
      WHERE order_date IS NOT NULL
      GROUP BY DATETRUNC(month, order_date)
    ) t

-- Using partition by year
SELECT
  order_date,
  sales_year,
  total_sales,
  SUM(total_sales) OVER (
    PARTITION BY sales_year
    ORDER BY order_date
  ) AS running_total_sales,
  avg_price_per_month,
  AVG(avg_price_per_month) OVER (
  PARTITION BY sales_year
  ORDER BY order_date
  ) AS moving_average_price
FROM (
  SELECT 
    DATETRUNC(month, order_date) AS order_date,
    YEAR(order_date) AS sales_year,
    SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price_per_month
  FROM gold.fact_sales
  WHERE order_date IS NOT NULL
  GROUP BY DATETRUNC(month, order_date), YEAR(order_date)
)t;


-----------------------------------------------------------------------------------------------------------------------------
-- Performance Analysis - measures success and compare performance.
-----------------------------------------------------------------------------------------------------------------------------

/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales*/

WITH yearly_product_sales AS (
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY
		YEAR(f.order_date),
		p.product_name
)

SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END avg_change,
	-- Year-over-year Analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py, -- py -previous year
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year

-----------------------------------------------------------------------------------------------------------------------------
/* Part-to- Whole - analyze how an individual part is performing compared to the overall, helps 
understand which category has the greatest impact on the business*/
-----------------------------------------------------------------------------------------------------------------------------

-- Which categories contribute the most to overall sales?
	WITH category_sales AS (
	SELECT 
		category,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	GROUP BY category
)

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


-----------------------------------------------------------------------------------------------------------------------------
/* Data Segmentation - Group the data based on a specific range that helps understand the correlation between two measures*/
-----------------------------------------------------------------------------------------------------------------------------


/*Segment products into cost ranges and 
count how many products fall into each segment*/


WITH product_segments AS (
	SELECT
		product_key,
		product_name,
		cost,
		CASE 
			WHEN cost< 100 THEN 'Below 100'              --convert measure to dimension
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END cost_range
	FROM gold.dim_products
)

SELECT
	cost_range,
	COUNT (product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


/* Group customers into three segments based on their spending behaviour:
	- VIP: Customers with at least 12 months of history and spending more than �5000.
	- Regular: Customers with at least 12 months of history but spending �5000 or less.
	- New: Customers with a lifespan less than 12 months.
AND find the total number of customers by each group
*/

WITH customer_spending AS(
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
GROUP BY c.customer_key),

customer_segment AS(
	SELECT 
		customer_key,
		CASE 
			 WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END customer_segment
	FROM customer_spending
)

SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_segment
ORDER BY total_customers DESC;


/*
=============================================================================================================================
Customer Report
=============================================================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours

Highlights:
	1. Gathers essential fields suchs as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
	4. Calculates valuable KPIs:
	   - recency (months since last order)
	   - average order value
	   - average monthly spend
=============================================================================================================================
*/
GO
CREATE VIEW gold.report_customers AS

WITH base_query AS(
/*--------------------------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------------------------------------------------*/
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregration AS(
/*--------------------------------------------------------------------------------------------------------------------------
2) Customer Aggregrations: Summarizes key metrics at the customer level
--------------------------------------------------------------------------------------------------------------------------*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age
)

/*--------------------------------------------------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output
--------------------------------------------------------------------------------------------------------------------------*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 30 and 39 THEN '30-39'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE 'Above 50'
	END AS age_group,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- COMPUTE average order value (AVO)
	CASE 
		 WHEN total_orders = 0 THEN 0
		 ELSE total_sales/ total_orders
	END AS avg_order_value,
	-- Compute average monthly spend
	CASE 
		 WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/ lifespan
	END AS avg_monthly_spend
FROM customer_aggregration;
GO

/* Querying from Customer Report View Created*/
SELECT
	customer_segment,
	COUNT(customer_number) AS total_customers,
	SUM(total_sales) total_sales
FROM gold.report_customers
GROUP BY customer_segment;

/*
=============================================================================================================================
Product Report
=============================================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours

Highlights:
	1. Gathers essential fields suchs as product names, category, subcategory and cost.
	2. Segments products by revenue to identify High-Perfromers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customers (unique)
	   - lifespan (in months)
	4. Calculates valuable KPIs:
	   - recency (months since last sale)
	   - average order revenue (AOR)
	   - average monthly revenue
=============================================================================================================================
*/
GO
CREATE VIEW gold.report_products AS

WITH base_query AS(
/*--------------------------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------------------------------------------------*/
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL -- only consider valid sales dates
),

product_aggregration AS(
/*--------------------------------------------------------------------------------------------------------------------------
2) Product Aggregrations: Summarizes key metrics at the product level
--------------------------------------------------------------------------------------------------------------------------*/
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_sale_date,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
	FROM base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		cost
)

/*--------------------------------------------------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output
--------------------------------------------------------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE 
		 WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales >= 10000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,
	lifespan
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- COMPUTE average order revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/ total_orders
	END AS avg_order_revenue,
	-- Compute average monthly revenue
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/ lifespan
	END AS avg_monthly_revenue
FROM product_aggregration
GO

/* Querying from Product Report View Created*/
SELECT
product_segment,
SUM(total_sales) total_sales
FROM gold.report_products
GROUP BY product_segment 