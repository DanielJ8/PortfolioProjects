-----------------------------------------------------------------------------------------------------------------------------
-- Dimensions Exploration
-----------------------------------------------------------------------------------------------------------------------------

-- Get the unique countries where customers are from
SELECT DISTINCT country 
FROM gold.dim_customers
ORDER BY country;

-- Get a list of unique categories, subcategories, and products
SELECT DISTINCT category, subcategory, product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;