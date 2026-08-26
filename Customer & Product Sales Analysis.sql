-- ============================================================
-- CUSTOMER & PRODUCT SALES ANALYSIS
-- ============================================================
-- Database: qsn
-- Objective:
-- Analyze customer ordering behavior, product performance,
-- order value, reviews, payments, shipments and sales trends.
-- ============================================================

USE qsn;


-- ============================================================
-- SCENARIO 1: Total Orders by Customer
-- Business Question:
-- How many orders has each customer placed, including
-- customers who have never placed an order?
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name
ORDER BY
    total_orders DESC;


-- ============================================================
-- SCENARIO 2: Frequent Buyers
-- Business Question:
-- Which customers have placed more than 3 orders?
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name
HAVING COUNT(o.order_id) > 3
ORDER BY
    total_orders DESC;


-- ============================================================
-- SCENARIO 3: Total Quantity Sold by Product
-- Business Question:
-- How many units of each product have been sold?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products AS p
INNER JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_quantity DESC;


-- ============================================================
-- SCENARIO 4: Top 5 Products by Quantity Sold
-- Business Question:
-- Which 5 products have the highest sales volume?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products AS p
INNER JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_quantity DESC
LIMIT 5;


-- ============================================================
-- SCENARIO 5: Top 5 Revenue-Generating Products
-- Business Question:
-- Which 5 products generate the highest revenue?
-- Revenue = Quantity Sold × Product Price
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products AS p
INNER JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_revenue DESC
LIMIT 5;


-- ============================================================
-- SCENARIO 6: Customer Order Count with CASE
-- Business Question:
-- How should orders be categorized based on order value,
-- and how many orders has each customer placed?
-- ============================================================

SELECT
    customer_id,
    order_id,
    total_price,

    CASE
        WHEN total_price >= 900 THEN 'High'
        ELSE 'Normal'
    END AS order_category,

    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS customer_order_count

FROM orders;


-- ============================================================
-- SCENARIO 7: Order Value Classification
-- Business Question:
-- Classify orders into different value categories and
-- calculate the total order value for each category.
-- ============================================================

SELECT
    CASE
        WHEN total_price >= 5000 THEN 'High Value'
        WHEN total_price >= 2500 THEN 'Medium Value'
        WHEN total_price >= 1000 THEN 'Low Value'
        ELSE 'Very Low'
    END AS order_type,

    SUM(total_price) AS total_order_value

FROM orders

GROUP BY
    CASE
        WHEN total_price >= 5000 THEN 'High Value'
        WHEN total_price >= 2500 THEN 'Medium Value'
        WHEN total_price >= 1000 THEN 'Low Value'
        ELSE 'Very Low'
    END

ORDER BY
    total_order_value DESC;


-- ============================================================
-- SCENARIO 8: Count High-Value Orders
-- Business Question:
-- How many orders have a total value of at least 4,000?
-- ============================================================

SELECT
    COUNT(
        CASE
            WHEN total_price >= 4000 THEN 1
        END
    ) AS high_value_orders
FROM orders;


-- ============================================================
-- SCENARIO 9: Revenue from High-Value Orders
-- Business Question:
-- What is the total revenue generated from orders
-- worth at least 4,500?
-- ============================================================

SELECT
    SUM(
        CASE
            WHEN total_price >= 4500 THEN total_price
            ELSE 0
        END
    ) AS high_value_revenue
FROM orders;


-- ============================================================
-- SCENARIO 10: Order Distribution by Value
-- Business Question:
-- How are orders distributed across low, medium and
-- high-value categories?
-- ============================================================

SELECT
    CASE
        WHEN total_price < 2000 THEN 'Low'
        WHEN total_price <= 5000 THEN 'Medium'
        ELSE 'High'
    END AS order_category,

    COUNT(*) AS total_orders

FROM orders

GROUP BY
    CASE
        WHEN total_price < 2000 THEN 'Low'
        WHEN total_price <= 5000 THEN 'Medium'
        ELSE 'High'
    END

HAVING COUNT(*) > 10

ORDER BY
    total_orders DESC;


-- ============================================================
-- SCENARIO 11: Review Rating Availability
-- Business Question:
-- Which reviews have ratings and which reviews are missing
-- rating information?
-- ============================================================

SELECT
    review_id,
    rating,

    CASE
        WHEN rating IS NULL THEN 'Not Rated'
        ELSE 'Rated'
    END AS rating_status

FROM reviews;


-- ============================================================
-- SCENARIO 12: First Half vs Second Half Orders
-- Business Question:
-- How many orders were placed during the first and second
-- half of 2024?
-- ============================================================

SELECT
    CASE
        WHEN order_date BETWEEN '2024-01-01' AND '2024-06-30'
            THEN 'First Half'
        WHEN order_date BETWEEN '2024-07-01' AND '2024-12-31'
            THEN 'Second Half'
        ELSE 'Other Year'
    END AS date_period,

    COUNT(*) AS total_orders

FROM orders

GROUP BY
    CASE
        WHEN order_date BETWEEN '2024-01-01' AND '2024-06-30'
            THEN 'First Half'
        WHEN order_date BETWEEN '2024-07-01' AND '2024-12-31'
            THEN 'Second Half'
        ELSE 'Other Year'
    END

ORDER BY
    date_period;


-- ============================================================
-- SCENARIO 13: Customer Value Segmentation
-- Business Question:
-- How can customers be classified based on their total
-- spending?
-- ============================================================

SELECT
    c.customer_id,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_price) AS total_spending,

    CASE
        WHEN SUM(o.total_price) >= 4500 THEN 'VIP'
        WHEN SUM(o.total_price) >= 3500 THEN 'Premium'
        WHEN SUM(o.total_price) >= 1500 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment

FROM customers AS c

LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id

HAVING COUNT(o.order_id) >= 2

ORDER BY
    total_spending DESC;


-- ============================================================
-- SCENARIO 14: Product Performance Analysis
-- Business Question:
-- How can products be classified based on their price
-- performance and order activity?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(p.price) AS total_product_value,
    COUNT(oi.quantity) AS total_orders,

    CASE
        WHEN SUM(p.price) >= 200000 THEN 'Top Performance'
        WHEN SUM(p.price) >= 150000 THEN 'Good Performance'
        WHEN SUM(p.price) >= 100000 THEN 'Low Performance'
        ELSE 'Average'
    END AS performance_category

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name

HAVING COUNT(oi.quantity) >= 10

ORDER BY
    total_product_value DESC;


-- ============================================================
-- SCENARIO 15: Products with High Average Ratings
-- Business Question:
-- Which products have an average customer rating above 4?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    AVG(r.rating) AS avg_rating

FROM products AS p

INNER JOIN reviews AS r
    ON p.product_id = r.product_id

GROUP BY
    p.product_id,
    p.product_name

HAVING AVG(r.rating) > 4

ORDER BY
    avg_rating DESC;


-- ============================================================
-- SCENARIO 16: Incomplete Payment Transactions
-- Business Question:
-- Which orders have payment transactions that are not
-- completed?
-- ============================================================

SELECT
    o.order_id,
    p.transaction_status

FROM orders AS o

INNER JOIN payment AS p
    ON o.order_id = p.order_id

WHERE p.transaction_status <> 'completed'

ORDER BY
    o.order_id;


-- ============================================================
-- SCENARIO 17: Shipment Status Analysis
-- Business Question:
-- How many shipments are present under each shipment status?
-- ============================================================

SELECT
    shipment_status,
    COUNT(*) AS total_shipments

FROM shipments

GROUP BY
    shipment_status

ORDER BY
    total_shipments DESC;


-- ============================================================
-- SCENARIO 18: Average Delivery Time
-- Business Question:
-- What is the average number of days taken to deliver
-- shipments?
-- ============================================================

SELECT
    AVG(
        DATEDIFF(delivery_date, shipment_date)
    ) AS avg_delivery_days

FROM shipments

WHERE delivery_date IS NOT NULL
  AND shipment_date IS NOT NULL;


-- ============================================================
-- SCENARIO 19: Monthly Order Trend
-- Business Question:
-- How many orders were placed each month?
-- ============================================================

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders

FROM orders

GROUP BY
    YEAR(order_date),
    MONTH(order_date)

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- BUSINESS ANALYSIS AREAS COVERED
-- ============================================================
-- 1. Customer Order Frequency
-- 2. Frequent Buyer Identification
-- 3. Product Sales Volume
-- 4. Top Products by Quantity
-- 5. Revenue Analysis
-- 6. CASE Statements
-- 7. Window Functions
-- 8. Conditional Aggregation
-- 9. Customer Segmentation
-- 10. Product Performance
-- 11. Review Analysis
-- 12. Payment Analysis
-- 13. Shipment Analysis
-- 14. Delivery Time Analysis
-- 15. Monthly Sales Trends
-- ============================================================


-- ============================================================
-- WINDOW FUNCTIONS PRACTICE
-- ============================================================

-- ============================================================
-- 1. OVER()
-- Find the total sales across all orders.
-- ============================================================

SELECT
    customer_id,
    order_id,
    SUM(total_price) OVER() AS total_sales
FROM orders;


-- ============================================================
-- 2. PARTITION BY
-- Find total sales generated by each customer.
-- ============================================================

SELECT
    customer_id,
    order_id,
    SUM(total_price) OVER(PARTITION BY customer_id) AS customer_total_sales
FROM orders;


-- ============================================================
-- 3. COUNT() OVER()
-- Find the total number of orders placed by each customer.
-- ============================================================

SELECT
    customer_id,
    order_id,
    COUNT(order_id) OVER(PARTITION BY customer_id) AS total_orders
FROM orders;


-- ============================================================
-- 4. ROW_NUMBER()
-- Assign a sequential number to each customer's orders
-- based on the order date.
-- ============================================================

SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS order_number
FROM orders;


-- ============================================================
-- 5. RANK()
-- Rank orders based on total price from highest to lowest.
-- ============================================================

SELECT
    order_id,
    customer_id,
    total_price,
    RANK() OVER(
        ORDER BY total_price DESC
    ) AS sales_rank
FROM orders;


-- ============================================================
-- 6. RUNNING TOTAL
-- Calculate cumulative sales over time.
-- ============================================================

SELECT
    order_date,
    total_price,
    SUM(total_price) OVER(
        ORDER BY order_date
    ) AS running_total
FROM orders;


-- ============================================================
-- 7. CUSTOMER-WISE RUNNING TOTAL
-- Calculate cumulative sales for each customer.
-- ============================================================

SELECT
    customer_id,
    order_date,
    total_price,
    SUM(total_price) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS customer_running_total
FROM orders;


-- ============================================================
-- 8. LAG()
-- Compare each order's sales with the previous order.
-- ============================================================

SELECT
    order_id,
    customer_id,
    order_date,
    total_price,
    LAG(total_price) OVER(
        ORDER BY order_date
    ) AS previous_order_sales
FROM orders;


-- ============================================================
-- 9. LEAD()
-- Compare each order's sales with the next order.
-- ============================================================

SELECT
    order_id,
    customer_id,
    order_date,
    total_price,
    LEAD(total_price) OVER(
        ORDER BY order_date
    ) AS next_order_sales
FROM orders;

-- ==========================================
-- SQL WINDOW FUNCTIONS
-- Table: orders
-- ==========================================


-- 1. OVER()
-- Question: Show total sales of all orders with every row.

SELECT
    customer_id,
    order_id,
    total_price,
    SUM(total_price) OVER() AS total_sales
FROM orders;


-- 2. PARTITION BY
-- Question: Show total sales for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    SUM(total_price) OVER(
        PARTITION BY customer_id
    ) AS customer_total_sales
FROM orders;


-- 3. ROW_NUMBER()
-- Question: Give a unique row number to each order for every customer.

SELECT
    customer_id,
    order_id,
    total_price,
    ROW_NUMBER() OVER(
        PARTITION BY customer_id
        ORDER BY total_price DESC
    ) AS row_num
FROM orders;


-- 4. RANK()
-- Question: Rank each customer's orders by total price.

SELECT
    customer_id,
    order_id,
    total_price,
    RANK() OVER(
        PARTITION BY customer_id
        ORDER BY total_price DESC
    ) AS price_rank
FROM orders;


-- 5. DENSE_RANK()
-- Question: Rank each customer's orders without gaps in ranking.

SELECT
    customer_id,
    order_id,
    total_price,
    DENSE_RANK() OVER(
        PARTITION BY customer_id
        ORDER BY total_price DESC
    ) AS dense_price_rank
FROM orders;


-- 6. LAG()
-- Question: Show the previous order price for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    LAG(total_price) OVER(
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS previous_order_price
FROM orders;


-- 7. LEAD()
-- Question: Show the next order price for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    LEAD(total_price) OVER(
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS next_order_price
FROM orders;


-- 8. RUNNING TOTAL
-- Question: Calculate cumulative sales for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    SUM(total_price) OVER(
        PARTITION BY customer_id
        ORDER BY order_id
    ) AS running_total
FROM orders;


-- 9. AVG()
-- Question: Show the average order value for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    AVG(total_price) OVER(
        PARTITION BY customer_id
    ) AS customer_average
FROM orders;


-- 10. MAX()
-- Question: Show the highest order value for each customer.

SELECT
    customer_id,
    order_id,
    total_price,
    MAX(total_price) OVER(
        PARTITION BY customer_id
    ) AS highest_order
FROM orders;