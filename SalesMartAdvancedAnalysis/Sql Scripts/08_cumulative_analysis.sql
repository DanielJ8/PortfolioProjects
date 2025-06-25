/*
-----------------------------------------------------------------------------------------------------------------------------
-- Cumulative Analysis - Helps understand if the business is growing or declining over time
-----------------------------------------------------------------------------------------------------------------------------

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER(), PARTITION BY
*/

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