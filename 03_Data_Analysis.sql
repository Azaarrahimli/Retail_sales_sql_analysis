---------------- Data Exploration
SELECT * FROM RETAIL_SALES;

SELECT * FROM retail_sales
WHERE quantity <= 0
OR sales < 0
OR profit IS NULL;

SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT region FROM retail_sales;
SELECT DISTINCT CATEGORY FROM retail_sales;
SELECT COUNT(DISTINCT product_id) FROM RETAIL_SALES; 
SELECT 
	MIN(order_date),
	MAX(order_date) 
FROM RETAIL_SALES;  

--------------- Data Analysis
--------------- Yearly Sales Trend Analysis

WITH yearly_trend AS(
SELECT 
	EXTRACT(YEAR FROM Order_date) years,
	round(avg(discount)*100,2) avg_discount_pct,
	round(sum(profit) / NULLIF(sum(sales),0) *100,2) profit_margin_pct,
	sum(quantity) total_quantity,
	round(sum(sales)) total_sales,
	round(sum(profit)) total_profit
FROM RETAIL_SALES 
GROUP BY EXTRACT(YEAR FROM Order_date)
)
SELECT 
	years,
	avg_discount_pct,
	profit_margin_pct,
	total_quantity,
	total_sales,
	total_profit,
	ROUND((total_sales - LAG(total_sales) OVER(ORDER BY years)) 
	/ lag(total_sales) over(ORDER BY years) * 100, 2) AS sales_yoy_pct,
	ROUND((total_profit - LAG(total_profit) OVER(ORDER BY years)) 
	/ LAG(total_profit) OVER(ORDER BY years) * 100, 2) AS profit_yoy_pct
FROM yearly_trend
ORDER BY years;

-- One of the reasons for the increase in sales over the years is the expansion of the business operations

SELECT	
	EXTRACT(YEAR FROM order_date) years,
	COUNT(DISTINCT(city)) branchs,
	COUNT(customer_id) customers
FROM RETAIL_SALES 
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years

--





