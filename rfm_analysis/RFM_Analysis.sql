--Inspecting the dataset structure (21 columns; preview shown in 3 screenshots)  

SELECT * FROM RETAIL_SALES;   

--Identify the minimum and maximum order dates in the dataset   

SELECT    
   	MIN(order_date) min_date,   
   	MAX(order_date) max_date   
FROM RETAIL_SALES    

--Since the dataset contains historical dates, we use the latest order date (max_date) as the reference date for analysis:   
   
WITH max_date_table AS (   
   	SELECT    
   	   	max(order_date) AS  max_date   
   	FROM RETAIL_SALES    
),     

--Now starting the RFM calculation   

RFM AS(   
   SELECT         	
      customer_id,
      max_date - MAX(order_date) AS recency,    	  
      COUNT(DISTINCT(order_id))  AS frequency,   
   	  SUM(sales)                 AS monetary    
   FROM RETAIL_SALES r   
   CROSS JOIN max_date m   
   GROUP BY r.customer_id, m.max_date    
),
  
--Assign scores from 1 to 5 for RFM  
  
RFM_score AS(   
   SELECT       
      customer_id,
      recency,
      frequency,
      monetary,
      NTILE(5) OVER(ORDER BY recency DESC)    AS r_score,   
      NTILE(5) OVER(ORDER BY frequency)       AS f_score,   
      NTILE(5) over(ORDER BY monetary)    	  AS m_score    
	FROM RFM   
)
  
--Validate score ranges.  
--This section is only for checking score distribution.  
--We will return to the main RFM flow afterward and continue the CTE pipeline.   
  
recency_range AS(   
   SELECT 
         r_score,   
   	     MIN(recency)     AS rmin,   
         MAX(recency)     AS rmax   
   FROM rfm_score   
   GROUP BY r_score   
),   
  
--The range should be calculated separately for Recency, Frequency, and Monetary 
  
  frequency_range AS(
  SELECT
        f_score,   
   	    MIN(frequency)   AS fmin,   
   		MAX(frequency)   AS fmax   
   FROM rfm_score   
   GROUP BY f_score   
),
  monetary_range as(   
  SELECT       
        m_score,   
        MIN(monetary) 	AS 	mmin,     
        max(monetary)   AS mmax
  FROM rfm_score   
  GROUP BY m_score   
)   
SELECT    
   	r.r_score,   
   	r.rmin,   
   	r.rmax,   
   	f.f_score,   
   	f.fmin,   
   	f.fmax,   
   	m.m_score,   
   	m.mmin,   
   	m.mmax   
FROM recency_range r   
JOIN frequency_range f   
   	ON r.r_score=f.f_score   
JOIN monetary_range m   
   	ON r.r_score=m.m_score   
ORDER BY r.r_score   

--Calculate the average RFM score and the combined RFM value (continuing from the main flow)
  
avg_rfm_concat AS(   
   	SELECT
        customer_id,    	  
        recency,
        frequency,   
        monetary,   
   	    r_score ||'-'|| f_score ||'-'|| m_score      AS R_F_M,     
        ROUND((r_score + f_score + m_score) / 3, 2)  AS AVG_rfm   
   	FROM rfm_score   
)   
  
--Creating Low / Mid / High value segments based on Monetary score  
--Note: Columns used in the next layer must be selected in the previous CTE.  
--Therefore, m_score was added to the prior layer.   
--Next, Create Low / Mid / High value segments based on the Monetary score   
  
value_seg AS(   
 	SELECT
      customer_id,    	  
      recency,
      frequency,
      monetary,
      R_F_M,   
      AVG_rfm,   
   	   CASE   
   	    	WHEN m_score in(1,2) THEN 'low'   
       		WHEN m_score = 3     THEN 'mid'   
   	    	WHEN m_score in(4,5) THEN 'high'   
       END AS value_segment   
   FROM avg_rfm_concat   
) 
  
--Segment customers based on their value    
  
customer_seg  AS(   
   	SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        R_F_M,
        AVG_RFM,
        value_segment,   
   	    CASE   
  	   	   	WHEN r_score >=4 AND f_score >=4 AND m_score >=4 THEN 'VIP'   
   			WHEN f_score >=3 AND m_score <4 THEN 'Regular'   
   	   		WHEN r_score <=3 AND r_score>1 THEN 'Dormat'   
   	      	WHEN r_score =1 THEN 'Churned'   
   		   	WHEN r_score >=4 AND f_score <=4 THEN 'New Customer'   
   	    END AS cust_seg   
   	FROM value_seg   
)   
   
   
-- Note: Since r_score, f_score, and m_score are used in the CASE WHEN logic  
-- these columns were included in the previous CTE layers.     
-- Next, create a VIEW based on the final output  
-- The full version of the SQL logic is provided below  
  
  
CREATE OR REPLACE VIEW RFM_ANALYSIS AS    
WITH max_date_table AS (   
   	SELECT    
   	   	max(order_date) AS  max_date   
   	FROM RETAIL_SALES    
),    
RFM AS(   
   	SELECT       
        customer_id,   
   	   	max_date - MAX(order_date) AS recency,    	  
        COUNT(DISTINCT(order_id)) AS frequency,   
   	   	SUM(sales) AS monetary    
   	FROM RETAIL_SALES r   
   	CROSS JOIN max_date_table m   
    GROUP BY r.customer_id, m.max_date    
),   
RFM_score AS(   
   	SELECT
         customer_id,    	  
         recency,     
         frequency,   
   	     monetary,   
   		 NTILE(5) OVER(ORDER BY recency DESC)    AS r_score,   
    	 NTILE(5) OVER(ORDER BY frequency)      	AS f_score,   
         NTILE(5) over(ORDER BY monetary)   	   	AS m_score    
   	FROM RFM   
), 
  avg_rfm_concat  AS(   
   	SELECT
         customer_id,   
         recency,   
   	     frequency,
         monetary,
         r_score,   
   	     f_score,
         m_score,   
   		 r_score ||'-'|| f_score ||'-'|| m_score     AS R_F_M,     
         ROUND((r_score + f_score + m_score) / 3, 2) AS AVG_rfm   
   	FROM rfm_score   
),
  value_seg  AS(   
   	SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        R_F_M,
        AVG_rfm, 
        r_score,
        f_score,     
        m_score,   
   	   	CASE   
   	   	   	WHEN m_score in(1,2) THEN 'low'   
   	   	   	WHEN m_score = 3    THEN 'mid'   
   	   	   	WHEN m_score in(4,5) THEN 'high'   
   	   	END AS value_segment   
   	FROM avg_rfm_concat   
), 
  customer_seg as(   
   	SELECT       
        customer_id,
        recency,
        frequency,
        monetary,
        R_F_M,
        AVG_RFM, 
        value_segment,   
   	   	CASE   
   	   	   	WHEN r_score >=4 AND f_score >=4 AND m_score >=4 THEN 'VIP'   
   	   	   	WHEN f_score >=3 AND m_score <4 THEN 'Regular'   
   	   	   	WHEN r_score <=3 AND r_score>1 THEN 'Dormat'   
   	   	   	WHEN r_score =1 THEN 'Churned'   
   	   	   	WHEN r_score >=4 AND f_score <=4 THEN 'New Customer'   
   	   	END AS cust_seg   
   	FROM value_seg   
)   
SELECT * FROM customer_seg   
   
--VIEW successfully created      

SELECT * FROM RFM_ANALYSIS   
   
--Check the number of customers in each value segment     

SELECT    
   	VALUE_SEGMENT ,   
   	COUNT(CUSTOMER_ID) AS cust_count    
FROM RFM_ANALYSIS    
GROUP BY VALUE_SEGMENT    
   
--Identify which segment has the highest customer share and which generates the highest total revenue    

SELECT   
  	CUST_SEG,  
  	COUNT(CUSTOMER_ID) AS cust_count,  
  	ROUND(SUM(MONETARY)) AS sum_monetary   
FROM RFM_ANALYSIS   
GROUP BY CUST_SEG   
ORDER BY sum_monetary DESC   
  
--Calculate the percentage share of each segment within the total customer base  

SELECT
    cust_seg,  
    COUNT(*) AS cust_count,  
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER()) AS percentage_segments  
FROM RFM_ANALYSIS  
GROUP BY cust_seg  
ORDER BY percentage_segments DESC;  
  
--Distribution of customer behavior segments within each value tier   

SELECT     
      value_segment, 
      cust_seg,   
      COUNT(*) AS cust_count  
FROM RFM_ANALYSIS  
GROUP BY value_segment, cust_seg  
ORDER BY value_segment, cust_count DESC;   
 

