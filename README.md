# Elevate-Labs-Task4
Use SQL queries to extract and analyze data from a database


readme_content = """# Ecommerce SQL Data Analysis

## 📌 Project Overview
This project demonstrates the use of **SQL for Data Analysis** on an **E-commerce dataset**.  
It was completed as part of a **Data Analyst Internship Task**.  
The goal was to manipulate, analyze, and extract insights from structured data using SQL.

---

## 📂 Files Included
- `ecommerce_assignment_queries.sql` → Contains all SQL queries used in the task.
- `README.md` → Documentation of the project, queries, and outcomes.

---

## ⚙️ Tools Used
- **MySQL 8.0**  
- Dataset: *E-commerce Dataset (CSV file imported into MySQL)*  

---

## 📝 Key SQL Concepts Covered
- **Database & Table Creation**
- **Data Import with `LOAD DATA INFILE`**
- **Data Cleaning using `TRIM` and conversions**
- **Indexes for Query Optimization**
- **Aggregate Functions (`SUM`, `AVG`, `COUNT`)**
- **GROUP BY and HAVING Clauses**
- **Views (`CREATE VIEW`)**
- **Subqueries**
- **Joins (INNER JOIN and Self-JOIN)**

---

## 🔎 Queries Implemented

### 1. Database & Table Setup
- Created database `ecommerce_assignment`  
- Created `orders` table with fields like `Order_Date`, `Customer_Id`, `Product`, `Sales`, `Profit`, etc.  
- Loaded dataset into MySQL using `LOAD DATA INFILE`.

### 2. Data Cleaning
- Removed extra spaces using `TRIM`.  
- Ensured proper datetime formats.  

### 3. Indexing for Optimization
- Created indexes on `Product`, `Order_Date`, and `Customer_Id`.  

### 4. Data Analysis Queries
- **Total Sales and Profit**
- **Top 10 Products by Sales**
- **Sales by Product Category**
- **Monthly Sales View**
- **Average Order Value**
- **ARPU (Average Revenue Per User)**
- **Orders by Device Type and Login Type**
- **Critical Orders with Negative Profit**
- **Impact of Discounts on Profitability**
- **Products Above Average Sales**
- **Repeat Customers**
- **Top 10 Customers**
- **Top 3 Products per Category (using Window Functions)**

### 5. Joins
- Created a `customers` table with sample customer names.  
- Demonstrated **INNER JOIN** with `orders` table to get customer-wise sales.  
- Demonstrated **SELF-JOIN** to find customers buying the same products.

---

## 📊 Example Insights Gained
- **Total Sales:** 7.8M+  
- **Total Profit:** 3.6M+  
- **Top-selling Product:** T-Shirts  
- **Top Category:** Fashion  
- **Best Customers:** High lifetime sales identified  
- **Discounted Sales:** Lower average profit margin compared to non-discounted sales  

---

## 🚀 How to Run
1. Open MySQL and create the database using the provided `.sql` file: 
