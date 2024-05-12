--cus_trans_2009_10 Table
select * from cus_trans_2009_10;


--Cus_transaction_2010_11 Table
select * from cus_trans_2010_11;

--Count Of cus_trans_2009_10 Table
select Count(*) from cus_trans_2009_10;

--Count Of cus_trans_2009_10 Table
select Count(*) from cus_trans_2010_11;


--CLEANING DATA--

--1. Identifying and deleting any rows with Null values in each table:-
--I can take Average and replace the null values as well but that won't be a correct approach in case of this data set.

DELETE FROM cus_trans_2009_10
WHERE Invoice IS NULL
   OR StockCode IS NULL
   OR Description IS NULL
   OR Quantity IS NULL
   OR InvoiceDate IS NULL
   OR Price IS NULL
   OR Customer_ID IS NULL
   OR Country IS NULL;



DELETE FROM cus_trans_2010_11
WHERE Invoice IS NULL
   OR StockCode IS NULL
   OR Description IS NULL
   OR Quantity IS NULL
   OR InvoiceDate IS NULL
   OR Price IS NULL
   OR Customer_ID IS NULL
   OR Country IS NULL;

--1. Identifying and deleting any rows with Duplicate values in each table:-

DELETE FROM cus_trans_2009_10
WHERE ROWID IN (
    SELECT ROWID
    FROM (
        SELECT ROWID,
               ROW_NUMBER() OVER (PARTITION BY Invoice, StockCode, Customer_Id ORDER BY Invoice) AS rn
        FROM cus_trans_2009_10
    )
    WHERE rn > 1
);


DELETE FROM cus_trans_2010_11
WHERE ROWID IN (
    SELECT ROWID
    FROM (
        SELECT ROWID,
               ROW_NUMBER() OVER (PARTITION BY Invoice, StockCode, Customer_Id ORDER BY Invoice) AS rn
        FROM cus_trans_2010_11
    )
    WHERE rn > 1
);


-- Trimming spaces in columns 

UPDATE cus_trans_2009_10
SET Invoice = TRIM(Invoice),
    StockCode = TRIM(StockCode),
    Description = TRIM(Description),
    Customer_Id = TRIM(Customer_Id),
    Country = TRIM(Country);

-- Trim spaces in columns in cus_trans_2010_11 table:

UPDATE cus_trans_2010_11
SET Invoice = TRIM(Invoice),
    StockCode = TRIM(StockCode),
    Description = TRIM(Description),
    Customer_Id = TRIM(Customer_Id),
    Country = TRIM(Country);
    
--CLEANING DATA

DELETE FROM cus_trans_2009_10_without_cancelled_invoices
WHERE Stockcode = 'M';

DELETE FROM cus_trans_2010_11_without_cancelled_invoices
WHERE Stockcode = 'M';

DELETE FROM cus_trans_2009_10_without_cancelled_invoices
WHERE TO_CHAR(Invoicedate, 'YYYY') NOT BETWEEN '2009' AND '2010';

DELETE FROM cus_trans_2010_11_without_cancelled_invoices
WHERE TO_CHAR(Invoicedate, 'YYYY') NOT BETWEEN '2010' AND '2011';


--2. Exploratory Data Analysis (EDA)

--Descriptive Statistics

SELECT 
    MIN(Quantity) AS MinQuantity,
    MAX(Quantity) AS MaxQuantity,
    ROUND(AVG(Quantity), 2) AS AvgQuantity,
   ROUND(STDDEV(Quantity), 2) AS StdDevQuantity
FROM cus_trans_2009_10;

SELECT 
    MIN(Quantity) AS MinQuantity,
    MAX(Quantity) AS MaxQuantity,
    ROUND(AVG(Quantity), 2) AS AvgQuantity,
   ROUND(STDDEV(Quantity), 2) AS StdDevQuantity
FROM cus_trans_2010_11;

--3. Since, Invoice contains Cancellations Records as well, It is better to Identify, Count And Separate them:-

SELECT Count(*)
FROM cus_trans_2009_10
WHERE Invoice LIKE 'C%';

SELECT Count(*)
FROM cus_trans_2010_11
WHERE Invoice LIKE 'C%';

--Creating New Table with Cleaned Data

CREATE TABLE cus_trans_2009_10_cleaned AS
SELECT *
FROM cus_trans_2009_10
WHERE Invoice NOT LIKE 'C%';

select * from cus_trans_2009_10_cleaned;

CREATE TABLE cus_trans_2010_11_cleaned AS
SELECT *
FROM cus_trans_2010_11
WHERE Invoice NOT LIKE 'C%';

select * from cus_trans_2010_11_cleaned;

--4. KEY PERFORMANCE INDICATORS (KPIs) to Provide Insights

--1. Total Revenue

SELECT SUM(Quantity * Price) AS TotalRevenue
FROM cus_trans_2009_10_cleaned;

SELECT SUM(Quantity * Price) AS TotalRevenue
FROM cus_trans_2010_11_cleaned;

--Creating New table
Create table cus_trans_2009_10_without_cancelled_invoices
AS Select * From cus_trans_2009_10_cleaned;

select * from cus_trans_2009_10_without_cancelled_invoices where invoice like 'C%';

Create table cus_trans_2010_11_without_cancelled_invoices
AS Select * From cus_trans_2010_11_cleaned;

select * from cus_trans_2010_11_without_cancelled_invoices where invoice like 'C%';

--2. Average Revenue per Customer

SELECT 
   Round(AVG(TotalRevenue),2) AS Avg_Revenue_Per_Customer
FROM (
    SELECT 
        Customer_Id, 
        SUM(Quantity * Price) AS TotalRevenue
    FROM cus_trans_2009_10_without_cancelled_invoices
    GROUP BY Customer_Id
);

SELECT 
   Round(AVG(TotalRevenue),2) AS Avg_Revenue_Per_Customer
FROM (
    SELECT 
        Customer_Id, 
        SUM(Quantity * Price) AS TotalRevenue
    FROM cus_trans_2010_11_without_cancelled_invoices
    GROUP BY Customer_Id
);


--Top 10 Customers by Revenue

SELECT 
    Customer_Id, 
    SUM(Quantity*Price) as TotalRevenue
FROM cus_trans_2009_10_without_cancelled_invoices
GROUP BY Customer_Id
ORDER BY TotalRevenue DESC
FETCH FIRST 10 ROWS ONLY;

SELECT 
    Customer_Id, 
    SUM(Quantity*Price) as TotalRevenue
FROM cus_trans_2010_11_without_cancelled_invoices
GROUP BY Customer_Id
ORDER BY TotalRevenue DESC
FETCH FIRST 10 ROWS ONLY;

--Top 10 Products by Revenue

SELECT
    StockCode,
    SUM(Quantity * Price) AS TotalRevenue
FROM cus_trans_2009_10_without_cancelled_invoices
GROUP BY StockCode
ORDER BY TotalRevenue DESC
FETCH FIRST 10 ROWS ONLY;

SELECT
    StockCode,
    SUM(Quantity * Price) AS TotalRevenue
FROM cus_trans_2010_11_without_cancelled_invoices
GROUP BY StockCode
ORDER BY TotalRevenue DESC
FETCH FIRST 10 ROWS ONLY;

--Monthly Revenue Trend

SELECT
    TO_CHAR(InvoiceDate, 'YYYY-MM') AS Month,
    SUM(Quantity * Price) AS Revenue
FROM cus_trans_2009_10_without_cancelled_invoices
GROUP BY TO_CHAR(InvoiceDate, 'YYYY-MM')
ORDER BY Month;

SELECT
    TO_CHAR(InvoiceDate, 'YYYY-MM') AS Month,
    SUM(Quantity * Price) AS Revenue
FROM cus_trans_2010_11_without_cancelled_invoices
GROUP BY TO_CHAR(InvoiceDate, 'YYYY-MM')
ORDER BY Month;

select * from cus_trans_2010_11_without_cancelled_invoices;


--Adding Total Revenue column

ALTER TABLE cus_trans_2009_10_without_cancelled_invoices
ADD TotalRevenue NUMBER;

UPDATE cus_trans_2009_10_without_cancelled_invoices
SET TotalRevenue = Quantity * PRICE;

ALTER TABLE cus_trans_2010_11_without_cancelled_invoices
ADD TotalRevenue NUMBER;

UPDATE cus_trans_2010_11_without_cancelled_invoices
SET TotalRevenue = Quantity * PRICE;

--Customer segmentation

SELECT
    CASE
        WHEN TotalRevenue > 10000 THEN 'High Value'
        WHEN TotalRevenue BETWEEN 5000 AND 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerType,
    COUNT(*) AS CustomerCount,
    SUM(TotalRevenue) AS TotalRevenue
FROM cus_trans_2009_10_without_cancelled_invoices
GROUP BY CASE
        WHEN TotalRevenue > 10000 THEN 'High Value'
        WHEN TotalRevenue BETWEEN 5000 AND 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END;


SELECT
    CASE
        WHEN TotalRevenue > 10000 THEN 'High Value'
        WHEN TotalRevenue BETWEEN 5000 AND 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerType,
    COUNT(*) AS CustomerCount,
    SUM(TotalRevenue) AS TotalRevenue
FROM cus_trans_2010_11_without_cancelled_invoices
GROUP BY CASE
        WHEN TotalRevenue > 10000 THEN 'High Value'
        WHEN TotalRevenue BETWEEN 5000 AND 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END;


