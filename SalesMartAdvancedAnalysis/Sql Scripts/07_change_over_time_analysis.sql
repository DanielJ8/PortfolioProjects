/*
-----------------------------------------------------------------------------------------------------------------------------
--Change-Over-Time -Track trends and identify seasonality in data

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
-----------------------------------------------------------------------------------------------------------------------------
*/

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