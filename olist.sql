-- Olist E-Commerce Sales Analysis
-- Database: Olist (SQLite)
-- Dataset: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- Description: SQL analysis across 8 relational tables answering
-- 5 core business questions on revenue, delivery,
-- retention, trends, and seller performance.


-- 1. REVENUE BY PRODUCT CATEGORY (English)
-- Joins order_items → products → category_translation
-- to get English category names with total revenue.
-- Top category: Health Beauty (~$1.26M)

SELECT
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN category_translation t ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY revenue DESC;


-- 2. REVENUE BY STATE
-- Chains order_items → orders → customers to tag
-- each sale with the customer's state.
-- Top state: SP (São Paulo) at ~$5.2M.

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 3. AVERAGE DELIVERY LATENESS BY REVIEW SCORE
-- Uses JULIANDAY() to calculate days between actual delivery
-- and estimated delivery date. Negative = arrived early.
-- Finding: 5-star orders arrived ~8.5 days earlier than 1-star.

SELECT
    r.review_score,
    ROUND(AVG(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_estimated_delivery_date)
    ), 2) AS avg_days_early_late
FROM orders o
JOIN reviews r ON r.order_id = o.order_id
GROUP BY r.review_score
ORDER BY r.review_score;


-- 4. REPEAT CUSTOMER RATE
-- Uses customer_unique_id (stable across orders) vs customer_id
-- (which resets per order) to correctly identify repeat buyers.
-- Uses chained CTEs and CAST to avoid integer division.
-- Finding: Only 3.12% of customers ever placed a second order.

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.customer_id) AS order_count
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
repeat_customers AS (
    SELECT COUNT(*) AS repeat_count
    FROM customer_order_counts
    WHERE order_count > 1
),
distinct_customers AS (
    SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
    FROM customers
)
SELECT
    repeat_count,
    total_customers,
    ROUND(CAST(repeat_count AS FLOAT) / total_customers * 100, 2) AS repeat_rate_pct
FROM repeat_customers, distinct_customers;


-- 5. MONTHLY REVENUE WITH MONTH-OVER-MONTH CHANGE
-- CTE computes monthly revenue using STRFTIME for date parsing.
-- LAG() window function pulls previous month's revenue for
-- comparison without a self-join.
-- Peak: November 2017 (likely Black Friday/holiday season).

WITH monthly_revenue AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS mom_change
FROM monthly_revenue
ORDER BY month;


-- 6. TOP SELLERS BY REVENUE, ORDER VOLUME, AND REVIEW SCORE
-- Combines order_items, sellers, and reviews to give a
-- complete picture of seller performance across 3 dimensions.
-- Notable: Seller 3 has highest order volume but lowest
-- avg review score (3.80) among top 10.

SELECT
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(oi.order_id) AS num_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
JOIN reviews r ON r.order_id = oi.order_id
GROUP BY oi.seller_id
ORDER BY revenue DESC
LIMIT 10;
