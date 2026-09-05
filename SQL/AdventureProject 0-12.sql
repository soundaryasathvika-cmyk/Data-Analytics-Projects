-- 0. Union of Fact Internet sales and Fact internet sales new

CREATE SCHEMA IF NOT EXISTS AdventureWorksDM;
USE AdventureWorksDM;
CREATE TABLE Sales AS
SELECT
    ProductKey,
    OrderDateKey,
    DueDateKey,
    ShipDateKey,
    CustomerKey,
    SalesOrderNumber,
    OrderQuantity,
    SalesAmount
FROM FactInternetSales

UNION ALL

SELECT
    ProductKey,
    OrderDateKey,
    DueDateKey,
    ShipDateKey,
    CustomerKey,
    SalesOrderNumber,
    OrderQuantity,
    SalesAmount
FROM Fact_Internet_Sales_New;

-- 1.Lookup the productname from the Product sheet to Sales sheet.
USE AdventureWorksDM;
SELECT
    f.ProductKey,
    p.EnglishProductName AS ProductName
FROM FactInternetSales f
JOIN DimProduct p
ON f.ProductKey = p.ProductKey;
    
SHOW TABLES;
DESCRIBE FactInternetSales;
DESCRIBE DimProduct;
SELECT
    f.ProductKey,
    p.EnglishProductName AS ProductName
FROM FactInternetSales f
JOIN DimProduct p
ON f.ProductKey = p.ProductKey;

CREATE TABLE Sales_With_Product AS
SELECT
    f.*,
    p.EnglishProductName AS ProductName
FROM FactInternetSales f
JOIN DimProduct p
ON f.ProductKey = p.ProductKey;

SELECT * 
FROM Sales_With_Product
LIMIT 10;

-- 2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.
USE AdventureWorksDM;

DESCRIBE FactInternetSales;
DESCRIBE DimCustomer;
DESCRIBE DimProduct;

CREATE TABLE Sales_Lookup AS
SELECT
    f.*,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName
FROM FactInternetSales f
JOIN DimCustomer c
ON f.CustomerKey = c.CustomerKey;

SELECT *
FROM Sales_Lookup
LIMIT 10;

DESC FactInternetSales;

-- 3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)

USE AdventureWorksDM;
SELECT 
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate
FROM FactInternetSales; 

SELECT
    OrderDateKey,

    -- A. Year
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS Year,

    -- B. Month No
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthNo,

    -- C. Month Full Name
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthFullName,

    -- D. Quarter (Q1, Q2, Q3, Q4)
    CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) AS Quarter,

    -- E. Year-Month (YYYY-MMM)
    DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,

    -- F. Weekday No (1=Sunday, 7=Saturday in MySQL)
    DAYOFWEEK(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayNo,

    -- G. Weekday Name
    DAYNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayName,

    -- H. Financial Month (Assume FY starts in April)
    CASE
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) >= 4
            THEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) - 3
        ELSE MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 9
    END AS FinancialMonth,

    -- I. Financial Quarter
    CONCAT(
        'Q',
        CASE
            WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 4 AND 6 THEN 1
            WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 7 AND 9 THEN 2
            WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 10 AND 12 THEN 3
            ELSE 4
        END
    ) AS FinancialQuarter

FROM FactInternetSales;

## Qno.4 Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)
desc sales;

SELECT
ProductKey,
UnitPrice,
OrderQuantity,
UnitPriceDiscountPct,
(UnitPrice * OrderQuantity) *
(1 - UnitPriceDiscountPct)AS SalesAmount
FROM sales;

## Qno.5 Calculate the Productioncost uning the columns(unit cost ,order quantity)
SELECT
    ProductKey,
    ProductStandardCost,
    OrderQuantity,
    (ProductStandardCost * OrderQuantity) AS ProductionCost
FROM sales;

## Qno.6 Calculate the profit.

show tables;
    SELECT 
    SalesOrderNumber,
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    TotalProductCost,
    (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS sales_amount,
    (
        SalesAmount - TotalProductCost
    ) AS profit
FROM factinternetsales;

##Q.NO.7 Create a Pivot table for month and sales (provide the Year as filter to select a particular Year)

SELECT
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS `Month No`,
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS `Month`,

    ROUND(SUM(CASE
        WHEN YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2010
        THEN SalesAmount ELSE 0 END),2) AS `2010`,

    ROUND(SUM(CASE
        WHEN YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2011
        THEN SalesAmount ELSE 0 END),2) AS `2011`,

    ROUND(SUM(CASE
        WHEN YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2012
        THEN SalesAmount ELSE 0 END),2) AS `2012`,

    ROUND(SUM(CASE
        WHEN YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2013
        THEN SalesAmount ELSE 0 END),2) AS `2013`,

    ROUND(SUM(CASE
        WHEN YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) = 2014
        THEN SalesAmount ELSE 0 END),2) AS `2014`

FROM sales

GROUP BY
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')),
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))

ORDER BY
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'));
    
        ## Qno.8 Create a Bar chart to show yearwise Sales

    SELECT
    YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')) AS Year,
    ROUND(
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)),
        2
    ) AS Total_Sales
FROM sales
GROUP BY YEAR(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
ORDER BY Year;

## Qno.9 Create a Line Chart to show Monthwise sales

SELECT
    MONTHNAME(
        STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')
    ) AS Month_Name,

    ROUND(
        SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)),
        2
    ) AS Total_Sales

FROM sales

GROUP BY
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d')),
    MONTHNAME(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))

ORDER BY
    MONTH(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'));
    
## Qno.10 Create a Pie chart to show Quarterwise sales

SELECT
    Quarter,
    ROUND(SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)), 2) AS Total_Sales
FROM
(
    SELECT
        CONCAT(
            'Q',
            QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
        ) AS Quarter,
        UnitPrice,
        OrderQuantity,
        UnitPriceDiscountPct
    FROM sales
) q
GROUP BY Quarter
ORDER BY Quarter;

## Qno.11 Create a combinational chart (bar and Line) to show Salesamount and Productioncost together

SELECT
    CONCAT(
        'Q',
        QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
    ) AS Quarter,

    ROUND(SUM(TotalProductCost), 2) AS ProductionCost,

    ROUND(SUM(SalesAmount), 2) AS SalesAmount

FROM sales

GROUP BY
    CONCAT(
        'Q',
        QUARTER(STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d'))
    )

ORDER BY Quarter;

-- 12.Build addtional KPI /Charts for Performance by Products, Customers, Region
USE AdventureWorksDM;

SELECT SUM(SalesAmount) AS Total_Sales
FROM FactInternetSales;
SELECT COUNT(DISTINCT SalesOrderNumber) AS Total_Orders
FROM FactInternetSales;
SELECT 
    SUM(SalesAmount) / COUNT(DISTINCT SalesOrderNumber) AS Avg_Order_Value
FROM FactInternetSales;

DESC DimProduct;
SELECT 
    SUM(f.SalesAmount - p.StandardCost * f.OrderQuantity) AS Total_Profit
FROM FactInternetSales f
JOIN  DimProduct p 
    ON f.ProductKey = p.ProductKey; 
    
SELECT 
    p.EnglishProductName,
    SUM(f.SalesAmount) AS Total_Sales
FROM FactInternetSales f
JOIN DimProduct p
ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC
LIMIT 10;

SELECT
    CONCAT(c.FirstName,' ',c.LastName) AS CustomerName,
    SUM(f.SalesAmount) AS TotalSales
FROM FactInternetSales f
JOIN DimCustomer c
ON f.CustomerKey=c.CustomerKey
GROUP BY CustomerName
ORDER BY TotalSales DESC;

SELECT 
    SUM(SalesAmount) AS Total_Sales,
    COUNT(DISTINCT CustomerKey) AS Total_Customers,
    COUNT(DISTINCT SalesOrderNumber) AS Total_Orders,
    AVG(SalesAmount) AS Avg_Sales
FROM FactInternetSales;
SELECT
    st.SalesTerritoryRegion,
    SUM(f.SalesAmount) AS Total_Sales
FROM FactInternetSales f
JOIN DimSalesTerritory st
    ON f.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryRegion
ORDER BY Total_Sales DESC;


