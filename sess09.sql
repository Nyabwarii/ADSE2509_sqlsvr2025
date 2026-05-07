/*Session 09 covers grouping, aggregatingdata, supqueries, joins, table expressions and data*/

use AdventureWorks2025

-- Grouping: Resource hours per WorkOrder
SELECT WorkOrderID, SUM(ActualResourceHrs) AS [Hours Per Order]
FROM Production.WorkOrderRouting
GROUP BY WorkOrderID;

-- Grouping: Resource hours per WorkOrder
SELECT WorkOrderID, SUM(ActualResourceHrs) AS [Hours Per Order]
FROM Production.WorkOrderRouting
GROUP BY WorkOrderID < 50;

-- Get the average prices of products from the product table in the production schema and group them by class
Select class, AVG(ListPrice) as 'Average List Price'
from Production Product
group by Class;

--Get the sum of the salesYTD column from the salesterritory table in the sales schema and group them by 
--names tha start with N OR E using the group by with all
select [group], sum(ytd)) as 'Total Region Sales'
from Sales.SalesTerritory
where [group] like 'N%' or [group] like 'E%'
group by all [group];

--Get/display the total sales in various regions from the salesterritory table in the sales schema for sales
--less than 6M
elsect [group], CONVERT(decimal(10,2), sum(salesytd)) as 'Total Region Sales'
from Sales.SalesTerritory
group by [group]
having sum(salesytd) < 6000000;

--Get or display the total sales in countries other than 'Australia' or 'Canada' using the cube operator
select [Name], CountryRegionCode, sum(salesytd)) as 'Total Region Sales'
from sale.SalesTerritory
where [Name] <> 'Australia' and [Name] not like 'Canada'
group by [Name], CountryRegionCode with Cube;

--Get or display the total salesin countries other than Austrlia or Canada using the rollup operator records in the resultset ith be sorted arranged in ascending order
select [Name]