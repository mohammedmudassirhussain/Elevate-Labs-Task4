--All Queries used in Task-4.
# Create the database
CREATE DATABASE IF NOT EXISTS ecommerce_assignment;
USE ecommerce_assignment;

--Table Creation
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  Order_Date DATETIME,
  Time TIME,
  Aging DOUBLE,
  Customer_Id INT,
  Gender VARCHAR(16),
  Device_Type VARCHAR(32),
  Customer_Login_type VARCHAR(32),
  Product_Category VARCHAR(128),
  Product VARCHAR(255),
  Sales DECIMAL(12,2),
  Quantity INT,
  Discount DECIMAL(6,3),
  Profit DECIMAL(12,2),
  Shipping_Cost DECIMAL(12,2),
  Order_Priority VARCHAR(32),
  Payment_method VARCHAR(64)
);

--Loading dataset
LOAD DATA LOCAL INFILE "C:\Users\sakin\Downloads\E-commerce Dataset.csv"
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Order_Date, @Time, Aging, Customer_Id, Gender, Device_Type, Customer_Login_type, Product_Category, Product, Sales, Quantity, Discount, Profit, Shipping_Cost, Order_Priority, Payment_method)
SET
  Order_Date = CASE
                 WHEN @Order_Date = '' THEN NULL
                 -- common formats; try datetime first, fallback to date only
                 WHEN STR_TO_DATE(@Order_Date, '%Y-%m-%d %H:%i:%s') IS NOT NULL THEN STR_TO_DATE(@Order_Date, '%Y-%m-%d %H:%i:%s')
                 ELSE STR_TO_DATE(@Order_Date, '%Y-%m-%d')
               END,
  Time = NULLIF(STR_TO_DATE(@Time, '%H:%i:%s'), '00:00:00'),
  Aging = NULLIF(Aging, ''),
  Sales = NULLIF(Sales, ''),
  Quantity = NULLIF(Quantity, ''),
  Discount = NULLIF(Discount, ''),
  Profit = NULLIF(Profit, ''),
  Shipping_Cost = NULLIF(Shipping_Cost, '');


-- Quick checks
SELECT COUNT(*) AS total_rows FROM orders;
SELECT * FROM orders LIMIT 10;
DESCRIBE orders;

-- Check for missing Order_Date
SELECT COUNT(*) FROM orders WHERE Order_Date IS NULL;

--Create helpful indexes
CREATE INDEX idx_orders_product ON orders(Product(100));
CREATE INDEX idx_orders_orderdate ON orders(Order_Date);
CREATE INDEX idx_orders_customer ON orders(Customer_Id);


--Total Sales & Profit
SELECT SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/total_sales_profit.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Top 10 Products by Sales
SELECT Product, SUM(Sales) AS total_sales, SUM(Quantity) AS total_qty
FROM orders
GROUP BY Product
ORDER BY total_sales DESC
LIMIT 10
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_10_products.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';


--Sales & Profit by Category
SELECT Product_Category, SUM(Sales) AS total_sales, SUM(Profit) AS total_profit
FROM orders
GROUP BY Product_Category
ORDER BY total_sales DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_by_category.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Monthly Sales (from view)
SELECT * FROM monthly_sales
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/monthly_sales.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Average Order Value (AOV)
SELECT AVG(Sales) AS avg_order_value
FROM orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/average_order_value.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--ARPU (Average Revenue per User)
SELECT SUM(Sales) / COUNT(DISTINCT Customer_Id) AS ARPU
FROM orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/arpu.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Orders by Device & Login Type
SELECT Device_Type, Customer_Login_type, COUNT(*) AS orders_count, SUM(Sales) AS total_sales
FROM orders
GROUP BY Device_Type, Customer_Login_type
ORDER BY orders_count DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders_by_device_login.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Critical Orders with Negative Profit
SELECT Order_Date, Customer_Id, Product, Sales, Profit, Order_Priority
FROM orders
WHERE Order_Priority = 'Critical' AND Profit < 0
LIMIT 100
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/critical_negative_profit.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Discount Impact
SELECT CASE WHEN Discount > 0 THEN 'discounted' ELSE 'no_discount' END AS discount_type,
       AVG(CASE WHEN Sales <> 0 THEN Profit / Sales END) AS avg_profit_margin,
       AVG(Profit) AS avg_profit
FROM orders
GROUP BY discount_type
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/discount_impact.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Products Above Average Sales
SELECT Product, SUM(Sales) AS total_sales
FROM orders
GROUP BY Product
HAVING SUM(Sales) > (
  SELECT AVG(prod_total) FROM (
    SELECT SUM(Sales) AS prod_total FROM orders GROUP BY Product
  ) AS t
)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_above_avg_sales.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Repeat Customers (same product multiple times)
SELECT Customer_Id, Product, COUNT(*) AS purchase_count
FROM orders
GROUP BY Customer_Id, Product
HAVING purchase_count > 1
ORDER BY purchase_count DESC
LIMIT 50
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/repeat_customers.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Top 10 Customers by Lifetime Sales
SELECT Customer_Id, SUM(Sales) AS lifetime_sales
FROM orders
GROUP BY Customer_Id
ORDER BY lifetime_sales DESC
LIMIT 10
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_10_customers.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

--Ranking (Top 3 Products per Category)
SELECT Product_Category, Product, total_sales, rank_in_category
FROM (
  SELECT Product_Category, Product, SUM(Sales) AS total_sales,
         RANK() OVER (PARTITION BY Product_Category ORDER BY SUM(Sales) DESC) AS rank_in_category
  FROM orders
  GROUP BY Product_Category, Product
) AS ranked
WHERE rank_in_category <= 3
ORDER BY Product_Category, rank_in_category
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_3_products_per_category.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- Joins Example
-- Create a simple customers table
CREATE TABLE customers (
    Customer_Id INT PRIMARY KEY,
    Customer_Name VARCHAR(100)
);

-- Insert some sample customers (for demo)
INSERT INTO customers (Customer_Id, Customer_Name)
VALUES 
(37077, 'Alice Johnson'),
(59173, 'Sophia Khan'),
(41066, 'David Lee'),
(50741, 'Maria Smith'),
(53639, 'John Carter');

-- Join query: Get customer names with their total sales
SELECT c.Customer_Name, SUM(o.Sales) AS total_sales, COUNT(o.id) AS order_count
FROM orders o
JOIN customers c ON o.Customer_Id = c.Customer_Id
GROUP BY c.Customer_Name
ORDER BY total_sales DESC
LIMIT 10;

-- Trim done
-- Trim text columns (fix leading/trailing spaces)
UPDATE orders SET Product = TRIM(Product), Product_Category = TRIM(Product_Category), Gender = TRIM(Gender);

-- If Order_Date loaded as VARCHAR by mistake (rare if you used STR_TO_DATE)
-- convert to DATETIME (only if needed)
ALTER TABLE orders MODIFY COLUMN Order_Date DATETIME;
UPDATE orders SET Order_Date = STR_TO_DATE(Order_Date, '%Y-%m-%d %H:%i:%s') WHERE Order_Date IS NOT NULL;




