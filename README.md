# Retail Sales SQL Analysis

---

## Project overview
The objective of this project is to analyze profit performance based on retail sales data and identify the key factors affecting it. The analysis focuses on sales trends, discount impact, regional performance, and margin risks. The goal is to uncover business inefficiencies and growth opportunities.

---

## Dataset Source / Information
The dataset used in this project was obtained from Kaggle and contains retail sales data. It includes information about customers, orders, products, and sales performance. The dataset consists of 9,994 rows and 21 columns.
[Dataset Link](https://www.kaggle.com/datasets/abiodunonadeji/united-state-superstore-sales?utm_source=chatgpt.com)

---

## Data Description
The dataset covers 2014–2017 and represents retail sales data across multiple regions. It includes information about orders, customers, products, and key metrics such as Sales, Profit, Quantity, and Discount.

---

## Data Cleaning
In the original dataset, date and financial columns were stored as VARCHAR. I created a new retail_sales table and converted these columns to DATE and NUMBER types. The data was inserted into the new table, and NULL and duplicate checks were performed

---

## Questions
1.  What are the top 10 most ordered products?
2. Which categories contribute the most to total sales?
3. How do sales trends change across years, months, and weekdays?
4. Which region shows the highest and lowest sales performance?
5. How are sales and profit distributed across customer segments?
6. Which sub-categories generate the lowest profit?
7. How do discounts impact sales and profit?
8. Are there products operating at negative margin?

---

## Findings

- Sales, customer count, and serviced cities increased over time; however, profit margins declined due to aggressive discounting. Discounts above 30% frequently led to negative profit.
- Sales peak in November–December and drop in January–February. The 1st and 5th weekdays generate the highest sales.
- West shows the strongest performance, while South performs weakest. Central applies high discounts, reducing profitability.
- Heavy discounting (40–80%) caused negative profit for several products, while lower discounts maintained positive margins.
- The Consumer segment drives the highest sales but operates with lower margins, making it more sensitive to discount levels.
- Customers were segmented by activity intervals and RFM analysis was applied to identify high-value and at-risk customers.
  
---

### Average Order Value (AOV)

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

## Tools
Oracle SQL – Data cleaning and analysis
