-- Data Exploration
SELECT COUNT(*) FROM retail_sales 

SELECT COUNT(DISTINCT customer_id) FROM retail_sales

SELECT DISTINCT region FROM retail_sales

SELECT DISTINCT CATEGORY FROM retail_sales

SELECT 
	MIN(order_date),
	MAX(order_date) 
FROM RETAIL_SALES  
 
