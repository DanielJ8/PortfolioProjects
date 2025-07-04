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

=============================================================================
Create Report: gold.report_products
=============================================================================
*/
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
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
FROM product_aggregration;
GO

/* Querying from Product Report View Created*/
SELECT
product_segment,
SUM(total_sales) total_sales
FROM gold.report_products
GROUP BY product_segment 