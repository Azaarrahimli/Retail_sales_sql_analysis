# Retail Sales SQL Analysis

## Project overview
The objective of this project is to analyze profit performance based on retail sales data and identify the key factors affecting it. The analysis focuses on sales trends, discount impact, regional performance, and margin risks. The goal is to uncover business inefficiencies and growth opportunities.

---

## Dataset Source / Information
The dataset covers 2014–2017 and represents retail sales data across multiple regions. It includes information about orders, customers, products, key metrics such as Sales, Profit, Quantity, and Discount.
The dataset used in this project was obtained from Kaggle. The dataset consists of 9,994 rows and 21 columns.
[Dataset Link](https://www.kaggle.com/datasets/abiodunonadeji/united-state-superstore-sales?utm_source=chatgpt.com)

---

## Data Cleaning
In the original dataset, date and financial columns were stored as VARCHAR. I created a new retail_sales table and converted these columns to DATE and NUMBER types. The data was inserted into the new table, and NULL and duplicate checks were performed

---
## Data Analysis & Findings

1. ### Yearly Sales Trend Analysis

|YEARS|AVG DISCOUNT|PROFIT MARGIN|TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|SALES YOY|PROFIT YOY|
|-----|----------------|-----------------|--------------|-----------|------------|-------------|--------------|
 |2014|          15.82%|           10.24%|          757,9|     483,966|       49,556|         NULL|          NULL|
 |2015|          15.56%|            13.1%|          797,9|     470,533|       61,619|       -2.78%|        24.34%|
 |2016|          15.47%|           13.43%|          983,7|     609,206|       81,795|       29.47%|        32.74%|
 |2017|          15.65%|           12.74%|         124,76|     733,215|       93,439|       20.36%|        14.24%|

> This table presents yearly trends in sales, profit, quantity, discount rate, and profit margin, along with year-over-year changes in sales and profit.

```sql
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
ORDER BY years
```

---
2. ### Monthly sales analysis

|MONTH|TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|
|------|--------------|-----------|------------|
|     1|          1,475|      94,925|        9,134|
|     2|          1,067|      59,751|       10,295|
|     3|          2,564|     205,005|       28,595|
|     4|          2,445|     137,481|       11,599|
|     5|          2,791|     155,029|       22,411|
|     6|          2,680|     152,719|       21,286|
|     7|          2,705|     147,238|       13,833|
|     8|          2,784|     159,044|       21,777|
|     9|          5,062|     307,650|       36,857|
|    10|          3,104|     200,323|       31,784|
|    11|          5,775|     352,461|       35,468|
|    12|          5,419|     325,294|       43,369|

> Sales are lowest in January and February, while **November** shows the highest sales.

```sql
SELECT 
	EXTRACT(MONTH FROM order_date) month_,
	SUM(quantity)  total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM RETAIL_SALES 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER by month_ 
```

---
3. ### Operational Expansion

|YEARS|BRANCHS|CUSTOMERS|
|-----|-------|---------|
 |2014|    268|     1,992|
 |2015|    275|     2,102|
 |2016|    320|     2,587|
 |2017|    350|     3,312|

> One of the reasons for the increase in sales over the years is the expansion in the number of serviced **cities**, which also led to an increase in customers.

```sql
SELECT	
	EXTRACT(YEAR FROM order_date) years,
	COUNT(DISTINCT(city)) branchs,
	COUNT(customer_id) customers
FROM RETAIL_SALES 
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years
```

---
4. ### Top Performing Region by Sales

|REGION |TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|
|-------|--------------|-----------|------------|
|West   |        12,266|    725,458|     108,418|
|East   |        10,616|    678,500|      91,535|
|South  |         6,209|    391,722|      46,749|
|Central|         8,780|    501,240|      39,706|

> **West** leads in sales, profit, and quantity.

```sql
SELECT 
	REGION ,
	SUM(QUANTITY) total_quantity ,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(PROFIT)) total_profit
FROM RETAIL_SALES 
GROUP BY REGION 
ORDER BY total_profit DESC 
```

---
5. ### Average Order Value (AOV)

|Regions|Total Revenue|Orders|AOV|
|-------|-------------|------|---|
|East|678,499.87|1,401|484.3|
|West|725,457.82|1,611|450.32|
|Central|501,239.89|1,175|426.59|
|South|391,721.91|822|476.55|

> Higher AOV in the **East** indicates customers purchase more premium or bulk items.

```sql
SELECT 
	region,
	ROUND(SUM(SALES),2) AS Total_Revenue,
	COUNT(DISTINCT(order_id)) AS orders,
	ROUND(SUM(sales) / COUNT(DISTINCT(order_id)),2) AS AOV
FROM RETAIL_SALES 
GROUP BY region;
```

---
6. ### Top 10 cities by total sales

| |CITY         |TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|
|-|-------------|--------------|-----------|------------|
|1|New York City|         3,417|    256,368|      62,037|
|2|Los Angeles  |         2,879|    175,851|      30,441|
|3|Philadelphia |         1,981|    109,077|     -13,838|
|4|San Francisco|         1,935|    112,669|      17,507|
|5|Seattle      |         1,590|    119,541|      29,156|
|6|Houston      |         1,466|     64,505|     -10,154|
|7|Chicago      |         1,132|     48,540|      -6,655|
|8|Columbus     |           834|     38,425|       5,909|
|9|San Diego    |           670|     47,521|       6,377|
|10|Springfield |           649|     43,054|       6,201|

> **New York City** has the highest sales and profit, while some cities show negative profit.

```sql
SELECT 
	CITY ,
	SUM(QUANTITY) total_quantity ,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(PROFIT)) total_profit
FROM RETAIL_SALES 
GROUP BY CITY 
ORDER BY total_quantity DESC 
FETCH FIRST	10 ROWS ONLY
```
---

7. ### Categories ranked by total sales

|CATEGORY       |TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|
|---------------|--------------|-----------|------------|
|Technology     |         6,939|    836,154|     145,455|
|Furniture      |         8,026|    741,718|      18,463|
|Office Supplies|        22,906|    719,047|     122,491|

```sql
SELECT 
	category,
	sum(quantity) total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC 
```

---
8. ### Top 10 sub categories by total sales

| |SUB CATEGORY|TOTAL QUANTITY|TOTAL SALES|TOTAL PROFIT|
|-|------------|--------------|-----------|------------|
|1|Phones      |         3,289|    330,007|      44,516|
|2|Chairs      |         2,354|    328,168|      26,602|
|3|Storage     |         3,158|    223,844|      21,279|
|4|Tables      |         1,241|    206,966|     -17,725|
|5|Binders     |         5,974|    203,413|      30,222|
|6|Machines    |           440|    189,239|       3,385|
|7|Accessories |         2,976|    167,380|      41,937|
|8|Copiers     |           234|    149,528|      55,618|
|9|Bookcases   |           868|    114,880|      -3,473|
|10|Appliances |         1,729|    107,532|      18,138|

```sql
SELECT 
	SUB_CATEGORY,
	sum(quantity) total_quantity,
	ROUND(SUM(sales)) total_sales,
	ROUND(SUM(profit)) total_profit
FROM retail_sales
GROUP BY SUB_CATEGORY
ORDER BY total_sales DESC 
FETCH FIRST 10 ROWS ONLY 
```
---

9. ### Discount Level Analysis

|DISCOUNT RANGE|SALES COUNT|TOTAL PROFIT|
|--------------|-----------|------------|
|0–20%         |        523|     -17,616|
|20–40%        |        414|     -38,945|
|40–60%        |        215|     -28,944|
|60%+          |        718|     -70,614|

> Number of sales and total profit with negative profit by discount level. Aggressive discounting is one of the main factors contributing to negative profit

```sql
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
```

---
## Questions
1. Which region generates the highest sales and profit?
2. Which cities generate the highest sales? (Top 10)
3. Which product categories generate the highest sales and profit?
4. Which sub-categories generate the highest sales? (Top 10)
5. How do discounts affect profitability?
6. Are there sales with negative profit and what may cause them?
7. How do sales and profit change throughout the year? (monthly trend)

---

## Findings

- Sales increased over time as the number of customers and serviced cities expanded.
- Sales peak in November and December, while January and February show the lowest performance.
- The West region generates the highest sales and profit, while the South region shows the weakest performance.
- New York City leads in both sales and profit, although some cities show negative profit despite high sales.
- Some products generate negative profit due to high discount levels.
- Lower discount rates generally maintain positive profit margins.
- Customers were segmented by activity intervals and RFM analysis was applied to identify high-value and at-risk customers.
  
---

## Tools
Oracle SQL – Data cleaning and analysis
