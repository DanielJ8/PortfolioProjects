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