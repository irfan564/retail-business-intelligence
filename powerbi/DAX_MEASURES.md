# 📐 Power BI Data Model & DAX Measures Reference

This document contains the complete **Star Schema Data Model architecture** and **production-grade DAX (Data Analysis Expressions) measures** for the `visualisation.pbix` Power BI report.

---

## 🏗️ 1. Data Model Architecture (Star Schema)

In Power BI Desktop, ensure the relationships between tables are configured as follows:

| Fact / Dimension | Table | Primary / Foreign Key | Cardinality | Cross Filter Direction |
|---|---|---|---|---|
| **Fact Table** | `Orders` | `order_id` | - | - |
| **Fact Table** | `Order_Items` | `order_id` → `Orders[order_id]` | Many-to-One (`*:1`) | Single |
| **Fact Table** | `Payments` | `order_id` → `Orders[order_id]` | Many-to-One (`*:1`) | Single |
| **Fact Table** | `Reviews` | `order_id` → `Orders[order_id]` | Many-to-One (`*:1`) | Single |
| **Dimension** | `Customers` | `customer_id` → `Orders[customer_id]` | One-to-Many (`1:*`) | Single |
| **Dimension** | `Products` | `product_id` → `Order_Items[product_id]` | One-to-Many (`1:*`) | Single |
| **Dimension** | `Sellers` | `seller_id` → `Order_Items[seller_id]` | One-to-Many (`1:*`) | Single |

---

## ⏱️ 2. DAX Calendar Table

To enable Time Intelligence functions in Power BI, create a calculated Calendar Table:

```dax
Dim_Calendar = 
ADDCOLUMNS (
    CALENDAR ( DATE ( 2016, 1, 1 ), DATE ( 2018, 12, 31 ) ),
    "Year", YEAR ( [Date] ),
    "Month Number", MONTH ( [Date] ),
    "Month Name", FORMAT ( [Date], "MMM" ),
    "Month Year", FORMAT ( [Date], "MMM YYYY" ),
    "Month Year Sort", YEAR ( [Date] ) * 100 + MONTH ( [Date] ),
    "Quarter", "Q" & FORMAT ( [Date], "Q" ),
    "Day of Week", FORMAT ( [Date], "ddd" ),
    "Is Weekend", IF ( WEEKDAY ( [Date], 2 ) >= 6, TRUE (), FALSE () )
)
```
*Relationship*: Mark `Dim_Calendar[Date]` as Date Table and link `Dim_Calendar[Date] 1:* Orders[order_purchase_timestamp]`.

---

## 📊 3. Core KPI DAX Measures

### 💰 Revenue Metrics

```dax
// 1. Total Gross Revenue
Total Revenue = 
SUM ( Orders[order_value] )
```

```dax
// 2. Total Order Volume
Total Orders = 
COUNTROWS ( Orders )
```

```dax
// 3. Average Order Value (AOV)
Average Order Value = 
DIVIDE ( [Total Revenue], [Total Orders], 0 )
```

```dax
// 4. Total Freight / Shipping Revenue
Total Freight = 
SUM ( Orders[shipping_cost] )
```

---

### 🚚 Logistics & Fulfillment Metrics

```dax
// 5. Total Delivered Orders
Delivered Orders = 
CALCULATE (
    [Total Orders],
    Orders[order_status] = "delivered"
)
```

```dax
// 6. Delivered Fulfillment Rate (%)
Fulfillment Rate Pct = 
DIVIDE ( [Delivered Orders], [Total Orders], 0 )
```

```dax
// 7. Late Deliveries Count
Late Orders Count = 
CALCULATE (
    [Total Orders],
    Orders[delivery_delay] > 0
)
```

```dax
// 8. Late Delivery Percentage (%)
Late Delivery Pct = 
DIVIDE ( [Late Orders Count], [Delivered Orders], 0 )
```

```dax
// 9. Average Delivery Lead Time (Days)
Avg Delivery Days = 
AVERAGE ( Orders[delivery_days] )
```

---

### ⭐ Customer Satisfaction Metrics

```dax
// 10. Average Review Score
Average Review Score = 
AVERAGE ( Reviews[review_score] )
```

```dax
// 11. 1-Star Review Percentage (%)
1 Star Review Pct = 
DIVIDE (
    CALCULATE ( COUNTROWS ( Reviews ), Reviews[review_score] = 1 ),
    COUNTROWS ( Reviews ),
    0
)
```

```dax
// 12. 5-Star Review Percentage (%)
5 Star Review Pct = 
DIVIDE (
    CALCULATE ( COUNTROWS ( Reviews ), Reviews[review_score] = 5 ),
    COUNTROWS ( Reviews ),
    0
)
```

---

## 📈 4. Time Intelligence DAX Measures (YoY & MoM Growth)

```dax
// 13. Year-over-Year (YoY) Revenue Growth Rate
YoY Revenue Growth Pct = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousYearRevenue = 
    CALCULATE (
        [Total Revenue],
        SAMEPERIODLASTYEAR ( Dim_Calendar[Date] )
    )
RETURN
DIVIDE ( CurrentRevenue - PreviousYearRevenue, PreviousYearRevenue, 0 )
```

```dax
// 14. Month-over-Month (MoM) Revenue Growth Rate
MoM Revenue Growth Pct = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousMonthRevenue = 
    CALCULATE (
        [Total Revenue],
        DATEADD ( Dim_Calendar[Date], -1, MONTH )
    )
RETURN
DIVIDE ( CurrentRevenue - PreviousMonthRevenue, PreviousMonthRevenue, 0 )
```

```dax
// 15. Cumulative Revenue Year-to-Date (YTD)
Cumulative Revenue YTD = 
TOTALYTD ( [Total Revenue], Dim_Calendar[Date] )
```

---

## 🎯 5. Advanced Analytical DAX Measures

```dax
// 16. Repeat Customer Percentage
Repeat Customer Rate = 
VAR TotalUniqueCustomers = DISTINCTCOUNT ( Orders[customer_id] )
VAR RepeatCustomers = 
    COUNTROWS (
        FILTER (
            VALUES ( Customers[customer_unique_id] ),
            CALCULATE ( COUNTROWS ( Orders ) ) > 1
        )
    )
RETURN
DIVIDE ( RepeatCustomers, TotalUniqueCustomers, 0 )
```

```dax
// 17. Pareto 80/20 Category Revenue Share
Top Categories Rev Share = 
VAR TotalSalesAllCategories = 
    CALCULATE ( [Total Revenue], ALL ( Products[product_category_name_english] ) )
RETURN
DIVIDE ( [Total Revenue], TotalSalesAllCategories, 0 )
```

---

## 📋 6. Recommended Dashboard Visual Layout

1. **Header Navigation Bar**: Title, Year Filter Slicer, Order Status Slicer, Region/State Slicer.
2. **Top Row KPI Cards**:
   - Card 1: Gross Revenue (`$13.59M`)
   - Card 2: Total Orders (`99.4K`)
   - Card 3: Average Order Value (`$136.68`)
   - Card 4: Avg Review Score (`4.09 ⭐`)
   - Card 5: Late Delivery Rate (`6.8%`)
3. **Main Visual Area**:
   - Visual 1 (Line Chart): Monthly Revenue & Order Volume over Time (Dim_Calendar[Month Year]).
   - Visual 2 (Bar Chart): Delivery Delay (Days) vs Review Score (1 to 5 Stars).
   - Visual 3 (Horizontal Bar Chart): Top 10 Product Categories by Revenue.
   - Visual 4 (Donut Chart): Payment Method Breakdown (Credit Card, Boleto, Voucher).
