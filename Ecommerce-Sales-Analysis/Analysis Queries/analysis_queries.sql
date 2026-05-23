#Creating Master Virtual Table
CREATE VIEW ecommerce_master AS
SELECT 
o.order_id,
o.order_purchase_timestamp,
c.customer_id,
c.customer_city,
oi.product_id,
oi.price,
p.product_category_name
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_items oi ON o.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id;


#KPI Metrics
##Total Revenue 
SELECT SUM(price) AS total_revenue
FROM ecommerce_master;

##Total Orders 
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_master;

##Total Customers 
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM ecommerce_master;

##Average order value
SELECT SUM(price) / COUNT(DISTINCT order_id) AS avg_order_value
FROM ecommerce_master;

#Product and Sales analysis
##Top categories by revenue
SELECT 
product_category_name,
SUM(price) AS revenue
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY revenue DESC
LIMIT 10;

##Top Products
SELECT 
product_id,
COUNT(*) AS total_sales
FROM ecommerce_master
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

#Customer and Location Analysis
##Top Cities
SELECT 
customer_city,
SUM(price) AS revenue
FROM ecommerce_master
GROUP BY customer_city
ORDER BY revenue DESC
LIMIT 10;

##Repeat Customers
SELECT 
customer_unique_id,
COUNT(DISTINCT order_id) AS orders
FROM ecommerce_master
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) > 1;

##Customers retention rate
SELECT 
COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END) * 100.0 
/ COUNT(DISTINCT customer_unique_id) AS repeat_customer_rate
FROM (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS order_count
    FROM ecommerce_master
    GROUP BY customer_unique_id
) t;

##updating master class
CREATE OR REPLACE VIEW ecommerce_master AS
SELECT 
o.order_id,
o.order_purchase_timestamp,
c.customer_unique_id,
c.customer_city,
oi.product_id,
oi.price,
p.product_category_name
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_items oi ON o.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id;

#Top 10 customers by revenue
SELECT 
customer_unique_id,
SUM(price) AS total_spent
FROM ecommerce_master
GROUP BY customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

#Revenue Contribution by Top Categories
SELECT 
product_category_name,
SUM(price) AS revenue,
ROUND(
SUM(price) * 100 / (SELECT SUM(price) FROM ecommerce_master),
2
) AS revenue_percentage
FROM ecommerce_master
GROUP BY product_category_name
ORDER BY revenue DESC;

#Delivery Performance Analysis
SELECT 
AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) 
AS avg_delivery_days
FROM olist_orders;
