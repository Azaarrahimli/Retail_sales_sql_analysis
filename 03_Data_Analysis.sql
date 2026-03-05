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

-- Find the top-performing region based on total sales

SELECT 
	REGION ,
	SUM(QUANTITY) total_quantity ,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(PROFIT)) total_profit
FROM RETAIL_SALES 
GROUP BY REGION 
ORDER BY total_profit DESC 

-- Top 10 cities by total sales

SELECT 
	CITY ,
	SUM(QUANTITY) total_quantity ,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(PROFIT)) total_profit
FROM RETAIL_SALES 
GROUP BY CITY 
ORDER BY total_quantity DESC 
FETCH FIRST	10 ROWS ONLY

-- Categories ranked by total sales

SELECT 
	category,
	sum(quantity) total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC 

-- Sub-categories ranked by total sales

SELECT 
	sub_category,
	sum(quantity) total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM retail_sales
GROUP BY sub_category
ORDER BY total_sales DESC 

-- Monthly sales analysis

SELECT 
	EXTRACT(MONTH FROM order_date) month_,
	SUM(quantity)  total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM RETAIL_SALES 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER by month_ 

-- Discount Level Analysis

SELECT
    CASE 
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.2 THEN '0–20%'
        WHEN discount <= 0.4 THEN '20–40%'
        WHEN discount <= 0.6 THEN '40–60%'
        ELSE '60%+'
    END AS discount_range,
    COUNT(*) AS sales_count,
    ROUND(SUM(profit)) AS total_profit
FROM retail_sales
WHERE profit < 0
GROUP BY
    CASE 
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.2 THEN '0–20%'
        WHEN discount <= 0.4 THEN '20–40%'
        WHEN discount <= 0.6 THEN '40–60%'
        ELSE '60%+'
    END
ORDER BY discount_range;









