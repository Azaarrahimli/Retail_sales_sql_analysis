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
- Sales, customer count, and the number of serviced cities (268 → 350) increased over the years. However, despite higher sales, profit margins declined. Discounts above 30% frequently resulted in negative profit, indicating significant risk in the discount strategy.
- Sales peak consistently in November and December, while January and February show the lowest performance.
- The 1st and 5th days of the week generate the highest sales, while the 3rd day records the lowest sales performance.
- West demonstrates the strongest overall performance, while South shows the weakest results. Central maintains moderate sales but lower profit due to frequent high discount applications.
- High discount rates were applied more intensively in the Central region. In Office Supplies, an 80% discount was applied 300 times, significantly reducing margins in both this category and Furniture.
- Analysis of three low-performing products shows that discounts between 40%–70% led to negative profit. The same products generated positive profit when sold with lower or no discounts, indicating that the issue lies in excessive discounting rather than the products themselves.
- The Consumer segment generates the highest sales and total profit; however, it operates with lower margins compared to other segments, making it more sensitive to discount levels.
- Customers were grouped into 0–6, 6–12, and 12–18 month intervals based on their order activity. This segmentation supports targeted campaign strategies for active and less active customers.
- An RFM analysis was conducted for the most recent year, identifying high-value, at-risk, and inactive customer segments.
- AOV
  
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
