-- ============================================================
-- Customer & Product Sales Analysis
-- ============================================================
-- Business Objective:
-- Analyze customer ordering behavior and product performance.
-- ============================================================


-- ============================================================
-- SCENARIO 1:
-- Find the total number of orders placed by each customer,
-- including customers who have never placed an order.
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
-- SCENARIO 2:
-- Identify customers who have placed more than 3 orders.
-- These customers can be considered frequent buyers.
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
-- SCENARIO 3:
-- Find the total quantity sold for each product.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_quantity DESC;


-- ============================================================
-- SCENARIO 4:
-- Identify the top 5 products based on total quantity sold.
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_quantity DESC
LIMIT 5;


-- ============================================================
-- SCENARIO 5:
-- Identify the top 5 products generating the highest revenue.
-- Revenue = Quantity Sold × Product Price
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * p.price) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    revenue DESC
LIMIT 5;


-- ============================================================
-- BUSINESS INSIGHTS:
-- 1. Analyze customer order frequency.
-- 2. Identify frequent buyers.
-- 3. Identify best-selling products.
-- 4. Identify top 5 products by quantity sold.
-- 5. Identify top 5 revenue-generating products.
-- ============================================================