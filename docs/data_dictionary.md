# 📖 Data Dictionary — Olist E-Commerce Dataset

This document details the schema, column definitions, data types, and primary/foreign keys for all 9 relational tables included in the Retail Business Intelligence repository.

---

## 1. `customers`
Contains customer identity and demographic locations.
- **Primary Key**: `customer_id`

| Column | Data Type | Description |
|---|---|---|
| `customer_id` | `VARCHAR(50)` | Key to the orders dataset. Each order has a unique customer_id. |
| `customer_unique_id` | `VARCHAR(50)` | Unique identifier of the actual customer (tracks repeat purchases). |
| `customer_zip_code_prefix` | `INT` | First 5 digits of customer zip code. |
| `customer_city` | `VARCHAR(100)` | Customer city name. |
| `customer_state` | `CHAR(2)` | Customer state abbreviation (e.g., SP, RJ). |

---

## 2. `orders`
Core transaction facts table containing timestamps and operational log metrics.
- **Primary Key**: `order_id`
- **Foreign Key**: `customer_id` → `customers.customer_id`

| Column | Data Type | Description |
|---|---|---|
| `order_id` | `VARCHAR(50)` | Unique identifier of the transaction order. |
| `customer_id` | `VARCHAR(50)` | Foreign key linking to customers table. |
| `order_status` | `VARCHAR(30)` | Status (`delivered`, `shipped`, `canceled`, `invoiced`, `processing`, etc.). |
| `order_purchase_timestamp` | `TIMESTAMP` | Timestamp when purchase was placed by customer. |
| `order_approved_at` | `TIMESTAMP` | Timestamp when payment was approved. |
| `order_delivered_carrier_date` | `TIMESTAMP` | Timestamp when order was handed to logistics carrier. |
| `order_delivered_customer_date` | `TIMESTAMP` | Actual timestamp when order arrived at customer address. |
| `order_estimated_delivery_date` | `TIMESTAMP` | Promised estimated delivery date shown to customer. |
| `delivery_days` | `DECIMAL(10,2)` | *Derived*: Days elapsed between purchase and delivery. |
| `delivery_delay` | `DECIMAL(10,2)` | *Derived*: Difference in days between actual and estimated delivery date. |
| `order_year` | `INT` | *Derived*: Year of order placement. |
| `order_month` | `INT` | *Derived*: Month number (1-12). |
| `order_month_name` | `VARCHAR(20)` | *Derived*: Month name (January - December). |
| `order_day` | `VARCHAR(20)` | *Derived*: Day of the week. |
| `is_weekend` | `BOOLEAN` | *Derived*: `True` if order placed on Saturday or Sunday. |
| `order_value` | `DECIMAL(10,2)` | *Derived*: Sum of product prices for the order. |
| `shipping_cost` | `DECIMAL(10,2)` | *Derived*: Sum of freight values for the order. |

---

## 3. `order_items`
Line item details for each order.
- **Foreign Keys**: 
  - `order_id` → `orders.order_id`
  - `product_id` → `products.product_id`
  - `seller_id` → `sellers.seller_id`

| Column | Data Type | Description |
|---|---|---|
| `order_id` | `VARCHAR(50)` | Unique order identifier. |
| `order_item_id` | `INT` | Sequential number identifying item number within the same order. |
| `product_id` | `VARCHAR(50)` | Unique product identifier. |
| `seller_id` | `VARCHAR(50)` | Unique seller identifier. |
| `shipping_limit_date` | `TIMESTAMP` | Seller shipping limit date for handling order to carrier. |
| `price` | `DECIMAL(10,2)` | Item price ($). |
| `freight_value` | `DECIMAL(10,2)` | Item freight/shipping cost ($). |

---

## 4. `payments`
Payment methods and installment details per order.
- **Foreign Key**: `order_id` → `orders.order_id`

| Column | Data Type | Description |
|---|---|---|
| `order_id` | `VARCHAR(50)` | Unique order identifier. |
| `payment_sequential` | `INT` | Sequence index for orders paid with multiple payment methods. |
| `payment_type` | `VARCHAR(30)` | Payment method (`credit_card`, `boleto`, `voucher`, `debit_card`). |
| `payment_installments` | `INT` | Number of payment installments chosen. |
| `payment_value` | `DECIMAL(10,2)` | Amount paid ($). |

---

## 5. `products`
Product catalog and dimensions.
- **Primary Key**: `product_id`

| Column | Data Type | Description |
|---|---|---|
| `product_id` | `VARCHAR(50)` | Unique product identifier. |
| `product_category_name` | `VARCHAR(100)` | Category name in Portuguese. |
| `product_category_name_english` | `VARCHAR(100)` | Translated category name in English. |
| `product_name_lenght` | `DECIMAL(10,2)` | Character length of product name. |
| `product_description_lenght` | `DECIMAL(10,2)` | Character length of product description. |
| `product_photos_qty` | `DECIMAL(10,2)` | Number of product photos published. |
| `product_weight_g` | `DECIMAL(10,2)` | Product weight in grams. |
| `product_length_cm` | `DECIMAL(10,2)` | Product length in centimeters. |
| `product_height_cm` | `DECIMAL(10,2)` | Product height in centimeters. |
| `product_width_cm` | `DECIMAL(10,2)` | Product width in centimeters. |

---

## 6. `reviews`
Customer review ratings and text feedback.
- **Foreign Key**: `order_id` → `orders.order_id`

| Column | Data Type | Description |
|---|---|---|
| `review_id` | `VARCHAR(50)` | Unique review identifier. |
| `order_id` | `VARCHAR(50)` | Unique order identifier. |
| `review_score` | `INT` | Satisfaction rating from 1 (worst) to 5 (best). |
| `review_comment_title` | `TEXT` | Comment title written by customer. |
| `review_comment_message` | `TEXT` | Review message text written by customer. |
| `review_creation_date` | `TIMESTAMP` | Timestamp when survey was sent to customer. |
| `review_answer_timestamp` | `TIMESTAMP` | Timestamp when customer completed review. |

---

## 7. `sellers`
Merchant and seller registry.
- **Primary Key**: `seller_id`

| Column | Data Type | Description |
|---|---|---|
| `seller_id` | `VARCHAR(50)` | Unique seller identifier. |
| `seller_zip_code_prefix` | `INT` | First 5 digits of seller zip code. |
| `seller_city` | `VARCHAR(100)` | Seller city name. |
| `seller_state` | `CHAR(2)` | Seller state abbreviation. |

---

## 8. `geolocation`
ZIP code geolocation coordinates for Brazilian cities.

| Column | Data Type | Description |
|---|---|---|
| `geolocation_zip_code_prefix` | `INT` | First 5 digits of zip code. |
| `geolocation_lat` | `DECIMAL(10,7)` | Latitude coordinate. |
| `geolocation_lng` | `DECIMAL(10,7)` | Longitude coordinate. |
| `geolocation_city` | `VARCHAR(100)` | City name. |
| `geolocation_state` | `CHAR(2)` | State code. |

---

## 9. `product_category_name_translation`
Translation table between Portuguese and English category names.

| Column | Data Type | Description |
|---|---|---|
| `product_category_name` | `VARCHAR(100)` | Category name in Portuguese. |
| `product_category_name_english` | `VARCHAR(100)` | Category name in English. |
