-- Corrected VARCHAR data types (sales, discount, profit, order_date, ship_date) from the raw dataset to appropriate NUMBER and DATE types to ensure accurate calculations and analysis.


CREATE TABLE retail_sales (
    row_id        NUMBER(38,0),
    order_id      VARCHAR2(50),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR2(50),
    customer_id   VARCHAR2(50),
    customer_name VARCHAR2(50),
    segment       VARCHAR2(50),
    country       VARCHAR2(50),
    city          VARCHAR2(50),
    state         VARCHAR2(50),        
    region        VARCHAR2(50),
    product_id    VARCHAR2(50),
    category      VARCHAR2(50),
    sub_category  VARCHAR2(50),
    product_name  VARCHAR2(128),
    sales         NUMBER(10,2),
    quantity      NUMBER(38,0),
    discount      NUMBER(5,2),
    profit        NUMBER(10,2),
    postal_code   VARCHAR2(10)
);

-- Data inserted into retail_sales table

INSERT INTO retail_sales (
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit,
    postal_code
)
SELECT
    row_id,
    order_id,
    TO_DATE(order_date, 'YYYY-MM-DD'),
    TO_DATE(ship_date, 'YYYY-MM-DD'),
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    TO_NUMBER(sales),
    TO_NUMBER(quantity),
    TO_NUMBER(discount),
    TO_NUMBER(profit),
    TO_CHAR(postal_code)
FROM retail_sales_analysis;

