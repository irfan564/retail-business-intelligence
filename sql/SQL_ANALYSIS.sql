-- ============================================================================
-- RETAIL BUSINESS INTELLIGENCE — SQL ANALYSIS
-- Dataset: Olist Brazilian E-Commerce (99,441 orders, 2016-2018)
-- Database: PostgreSQL
-- ============================================================================

-- ============================================================================
-- SECTION 1: TABLE CREATION (DDL - Data Definition Language)
-- Purpose: Define the relational schema for the e-commerce data warehouse
-- ============================================================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);



CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);


CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);




CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    delivery_days DECIMAL(10,2),
    delivery_delay DECIMAL(10,2),
    order_year INT,
    order_month INT,
    order_month_name VARCHAR(20),
    order_day VARCHAR(20),
    is_weekend BOOLEAN,
    order_value DECIMAL(10,2),
    shipping_cost DECIMAL(10,2)
);



CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght DECIMAL(10,2),
    product_description_lenght DECIMAL(10,2),
    product_photos_qty DECIMAL(10,2),
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2),
    product_category_name_english VARCHAR(100)
);

-- ============================================================================
-- SECTION 2: FOREIGN KEY CONSTRAINTS (Referential Integrity)
-- Purpose: Enforce relational integrity across all entity relationships
-- ============================================================================

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id);


ALTER TABLE order_items
ADD CONSTRAINT fk_orders_items_order
FOREIGN KEY(order_id)
references orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);



ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_sellers
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);



SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';

-- ============================================================================
-- SECTION 3: CORE KPIs (Revenue, Orders, Average Order Value)
-- Purpose: Calculate the primary business performance indicators
-- ============================================================================

-- Q1: Total Revenue
-- NOTE: Revenue is not filtered by order_status (includes all orders in the orders table).
-- See README KPI table for clarification on order status coverage [VERIFY].

SELECT ROUND(SUM(ORDER_VALUE),2)AS total_revenue
FROM ORDERS;

-- Q2: Total Orders

SELECT COUNT(*) AS total_orders
FROM ORDERS;

-- Q3: Average Order Value
-- NOTE: Revenue is not filtered by order_status (calculated across all orders in the orders table).
-- See README KPI table for clarification on order status coverage [VERIFY].

SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM orders;

-- Q4: Order Status Distribution

SELECT order_status, COUNT(*) AS order_status_count
FROM orders
GROUP BY order_status
ORDER BY order_status_count DESC;


-- ============================================================================
-- SECTION 4: BUSINESS ANALYSIS QUERIES
-- Purpose: Drill-down analysis across revenue, geography, categories,
--          sellers, payments, logistics, and customer satisfaction
-- ============================================================================

-- Q5: Monthly Revenue Breakdown (Growth Trend Analysis)

SELECT ORDER_YEAR,ORDER_MONTH_NAME,
ROUND(SUM(ORDER_VALUE),2) AS MONTHLY_REVENUE
FROM ORDERS
GROUP BY ORDER_YEAR,ORDER_MONTH,ORDER_MONTH_NAME
ORDER BY ORDER_YEAR,ORDER_MONTH;


-- Q6: State-Wise Revenue Distribution (Geographic Analysis)

SELECT C.CUSTOMER_STATE,
ROUND(SUM(O.ORDER_VALUE),2) AS REVENUE
FROM ORDERS O
JOIN CUSTOMERS C
ON C.CUSTOMER_ID=O.CUSTOMER_ID
GROUP BY C.CUSTOMER_STATE
ORDER BY REVENUE DESC;

-- Q7: Revenue by Product Category (Merchandising Strategy)
-- WARNING: Joining order_items with orders and summing order_value (SUM(o.order_value)) can double-count multi-item orders.
-- The dashboard's category chart uses SUM(price) from order_items instead.

SELECT P.PRODUCT_CATEGORY_NAME_ENGLISH,
ROUND(SUM(O.ORDER_VALUE),2) AS REVENUE
FROM ORDERS O
JOIN ORDER_ITEMS OT
ON O.ORDER_ID=OT.ORDER_ID
JOIN PRODUCTS P
ON OT.PRODUCT_ID=P.PRODUCT_ID
GROUP BY P.PRODUCT_CATEGORY_NAME_ENGLISH
ORDER BY REVENUE DESC;

-- Q8: Top Revenue-Generating Sellers (Marketplace Performance)
-- WARNING: Joining order_items with orders and summing order_value (SUM(o.order_value)) can double-count multi-item orders.
-- The dashboard's category chart uses SUM(price) from order_items instead.

SELECT S.SELLER_ID,
ROUND(SUM(O.ORDER_VALUE),2) AS REVENUE
FROM ORDERS O
JOIN ORDER_ITEMS OT
ON O.ORDER_ID=OT.ORDER_ID
JOIN SELLERS S
ON OT.SELLER_ID=S.SELLER_ID
GROUP BY S.SELLER_ID
ORDER BY REVENUE DESC;

-- Q9: Payment Method Usage (Financial Behavior Analysis)

SELECT PY.PAYMENT_TYPE,
COUNT(*) AS TOTAL
FROM ORDERS O
JOIN PAYMENTS PY
ON O.ORDER_ID=PY.ORDER_ID
GROUP BY PY.PAYMENT_TYPE
ORDER BY TOTAL DESC;

-- Q10: Delivery Performance vs Customer Satisfaction (Operational Quality)

SELECT
    r.review_score,
    ROUND(AVG(o.delivery_delay), 2) AS avg_delivery_delay,
    COUNT(*) AS total_orders
FROM orders o
JOIN reviews r
ON o.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


-- Q11: Top 10 Highest Revenue Orders

SELECT
    order_id,
    ROUND(order_value, 2) AS revenue
FROM orders
WHERE ORDER_VALUE IS NOT NULL
ORDER BY order_value DESC
LIMIT 10;

-- Q12: Revenue by Year (Annual Growth Comparison)


SELECT
    order_year,
    ROUND(SUM(order_value), 2) AS revenue
FROM orders
GROUP BY order_year
ORDER BY order_year;

-- Q13: Top 10 Cities by Number of Orders (Urban Demand Analysis)

SELECT
    c.customer_city,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;

-- Q14: Weekend vs Weekday Orders (Shopping Pattern Analysis)

SELECT
    is_weekend,
    COUNT(*) AS total_orders
FROM orders
GROUP BY is_weekend;


-- Q15: Top Product Categories by Quantity Sold (Volume Leaders)

SELECT
    p.product_category_name_english,
    COUNT(*) AS quantity_sold
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY quantity_sold DESC
LIMIT 10;

-- Q16: Average Product Price by Category (Pricing Strategy)

SELECT
    p.product_category_name_english,
    ROUND(AVG(oi.price),2) AS average_price
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY average_price DESC;

-- Q17: Sellers with Most Orders (Marketplace Leaders)

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- Q18: Average Installments by Payment Type (Credit Behavior)

SELECT
    payment_type,
    ROUND(AVG(payment_installments),2) AS avg_installments
FROM payments
GROUP BY payment_type;


-- Q19: Average Review Score by State (Regional Satisfaction)


SELECT
    c.customer_state,
    ROUND(AVG(r.review_score),2) AS avg_rating
FROM reviews r
JOIN orders o
ON r.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_rating DESC;

-- Q20: Percentage of Late Deliveries (SLA Compliance)
-- NOTE: The denominator COUNT(*) includes undelivered orders.

SELECT
ROUND(
100.0 * SUM(CASE WHEN delivery_delay > 0 THEN 1 ELSE 0 END)
/ COUNT(*),2
) AS late_delivery_percentage
FROM orders;

-- Q21: Top 10 Customers by Total Spending (High-Value Customers)

SELECT
    customer_id,
    ROUND(SUM(order_value), 2) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(order_value) IS NOT NULL
ORDER BY total_spent DESC
LIMIT 10;


-- Q22: Average Shipping Cost by State (Logistics Cost Analysis)
SELECT
    c.customer_state,
    ROUND(AVG(o.shipping_cost),2) AS avg_shipping_cost
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_shipping_cost DESC;

-- ============================================================================
-- SECTION 5: ADVANCED BUSINESS ANALYTICS (CTEs & Window Functions)
-- Purpose: Complex analytical queries demonstrating advanced SQL proficiency
--          including LAG, RANK, NTILE, Running Totals, RFM, and Cohort Analysis
-- ============================================================================

-- Q23: Month-over-Month (MoM) Revenue Growth Rate (LAG Window Function)
WITH monthly_rev AS (
    SELECT
        order_year,
        order_month,
        order_month_name,
        ROUND(SUM(order_value), 2) AS monthly_revenue
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY order_year, order_month, order_month_name
)
SELECT
    order_year,
    order_month,
    order_month_name,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
    ROUND(
        100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_year, order_month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_year, order_month), 0),
        2
    ) AS mom_growth_pct
FROM monthly_rev
ORDER BY order_year, order_month;


-- Q24: Cumulative (Running Total) Revenue Over Time
WITH monthly_rev AS (
    SELECT
        order_year,
        order_month,
        ROUND(SUM(order_value), 2) AS monthly_revenue
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY order_year, order_month) AS cumulative_revenue
FROM monthly_rev
ORDER BY order_year, order_month;


-- Q25: Top Sellers Ranked Within Each State (RANK PARTITION BY Window Function)
WITH seller_rev AS (
    SELECT
        s.seller_state,
        s.seller_id,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_state, s.seller_id
)
SELECT
    seller_state,
    seller_id,
    total_revenue,
    total_orders,
    RANK() OVER (PARTITION BY seller_state ORDER BY total_revenue DESC) AS rank_in_state
FROM seller_rev
ORDER BY seller_state, rank_in_state;


-- Q26: Customer RFM (Recency, Frequency, Monetary) Segmentation Matrix (NTILE)
WITH max_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_timestamp FROM orders
),
rfm AS (
    SELECT
        c.customer_unique_id,
        DATE_PART('day', (SELECT max_timestamp FROM max_date) - MAX(o.order_purchase_timestamp)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(o.order_value), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm
LIMIT 100;


-- Q27: Customer Cohort Analysis (Monthly Acquisition & Retention)
-- NOTE: This query returns active customers per cohort month, not retention percentages.
WITH customer_cohorts AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE_TRUNC('month', o.order_purchase_timestamp)) AS cohort_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
user_activities AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS activity_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT
    cohort_month,
    activity_month,
    COUNT(DISTINCT ua.customer_unique_id) AS active_customers
FROM customer_cohorts cc
JOIN user_activities ua ON cc.customer_unique_id = ua.customer_unique_id
GROUP BY cohort_month, activity_month
ORDER BY cohort_month, activity_month;




