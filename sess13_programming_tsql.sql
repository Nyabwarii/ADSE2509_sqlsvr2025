/* Session 13 covers various programming aspects of T-SQL. */

-- Switch to the customer database
use Cust_db_adse2509;

-- ---------------------------------------------------------------------------
-- Demonstrate working with a batch
-- ---------------------------------------------------------------------------
-- Create a batch
Begin Transaction
	-- Create the 'Company' table if it doesn't exist
	if OBJECT_ID('Company') is null
		Create Table Company
		(
			IDNum int identity(100,5),
			CompanyName nvarchar(100)
		);
	else
		Print 'The "Company" table already exists and will not be recreated!'


	-- Insert/add rows to the Company table
	Insert into Company
	values
	('A Bike Store'),
	('Progressive Sports'),
	('Modular Cycle Streams'),
	('Advanced Bike Components'),
	('Metropolitan Sports Supple'),
	('Aerobics Exercise Company'),
	('Associated Bikes'),
	('Exemplary Cycles')

	-- Display the above companies in ascending order
	Select IDNum 'Company ID', CompanyName as 'Name of Company'
	from Company
	order by CompanyName
commit; -- Rollback


-- ---------------------------------------------------------------------------
-- Demonstrate working with local variables
-- ---------------------------------------------------------------------------
-- Declare and use a local variable in a select statement/query
Declare @find nvarchar(30) = 'Man%'; -- Used to find/locate the last name of person(s) that start with 'Man'
Select p.FirstName, P.LastName, pp.PhoneNumber
from AdventureWorks2025.Person.Person P
Join AdventureWorks2025.Person.PersonPhone PP
on P.BusinessEntityID = PP.BusinessEntityID
where P.LastName like @find;

-- Declare a variable and assign it a value using the 'set' keyword
Declare @myVar nchar(40); -- Assigned 'NULL' by default
set @myVar = 'This is a test variable'; -- Assign some text to the variable
select @myVar 'Contents of @myVar'; -- Display the contents of @myVar variable

-- Use the select keyword to give/assign a value to a variable
Declare @var1 nvarchar(30); 
Select @var1 = 'Unnamed Company' -- Assignment statement
Select @var1 = Name
from AdventureWorks2025.Sales.Store
where BusinessEntityID = 10;

Select @var1 'Company Name'; -- Query the name of the store with businessEntityID 10 stored in '@var1' variable

-- ---------------------------------------------------------------------------
-- Demonstrate working with object synonyms
-- ---------------------------------------------------------------------------
-- Create a synonym for the 'Company' table using T-SQL code/statements
Create synonym [Kampuni] for dbo.Company;

-- Display the first 5 products and companies from the 'Products' and 'Company' tables using their synonyms
Select top(5) [name] from Bidhaa;
Select top(5) [Companyname] from Kampuni;

-- Demonstrate the use of @@Transcount & Begin...End statements
Begin Transaction
	if @@TRANCOUNT = 0
	Begin
		Select FirstName, MiddleName
		from AdventureWorks2025.Person.Person
		Where LastName like 'Andy';
		Print 'Rolling back the transaction 2 times would cause an error!';
	End
Rollback Transaction; --Commit Transaction
Print 'Rolled back transaction';

-- Declare a local variable that will store the price of mountain bike products from AD2025.Production.Product table
Declare @listPrice money
set @listPrice = 
(
	-- Query to retrieve the list price of the most expensive mountain bike products
	Select max(A.ListPrice)
	from AdventureWorks2025.Production.Product A
	join AdventureWorks2025.Production.ProductSubcategory B
	on A.ProductSubcategoryID = B.ProductSubcategoryID
	where A.Name like 'Mountain Bike%'
);

-- Check whether the price of mountain bike products exceed 3K and display and apt message
if @listPrice < 3000
	print 'All the products in this category can be purchased for less than 3000'
else
	print 'The price of some products in this category exceeds 3000'

-- ---------------------------------------------------------------------------
-- Demonstrate working with some mathematical functions in T-SQL
-- ---------------------------------------------------------------------------
/* The first value will be -1.01. This fails because the value is   
outside the range.*/  
DECLARE @angle float  
SET @angle = -1.01  
SELECT 'The ASIN of the angle is: ' + CONVERT(varchar, ASIN(@angle))  
GO  
  
-- The next value is -1.00.  
DECLARE @angle float  
SET @angle = -1.00  
SELECT 'The ASIN of the angle is: ' + CONVERT(varchar, ASIN(@angle))  
GO  
  
-- The next value is 0.1472738.  
DECLARE @angle float  
SET @angle = 0.1472738  
SELECT 'The ASIN of the angle is: ' + CONVERT(varchar, ASIN(@angle))  
GO 

-- ---------------------------------------------------------------------------
-- Demonstrate working with loops
-- ---------------------------------------------------------------------------
-- Display the even numbers between 10 - 95 using a while loop
Declare @flag int = 10;
while (@flag <= 95)
	Begin
		If(@flag % 2 = 0)
			print @flag
			set @flag += 1
			continue;
	End

-- Check whether the user defined function 'ufn_CustDates' exists and create it if it doesn't
If OBJECT_ID(N'ufn_CustDate',N'IF') is not null
	drop function ufn_custdate;
Go
Create function ufn_CustDate() Returns Table
as 
Return
(
	-- Query to get the customerid, duedate and shipdate for orders due before 2020
	Select A.CustomerID, B.DueDate, B.ShipDate
	from AdventureWorks2025.Sales.Customer A
	Left outer join
	AdventureWorks2025.Sales.SalesOrderHeader B on
	A.CustomerID = B.CustomerID and YEAR(B.duedate) < 2020
);

-- Execute the inline table valued function 'IF' ufn_custdate()
Select * from dbo.ufn_CustDate();

-- Check whether the user defined function 'ufn_GetAccountingEndDate' exists and create it if it doesn't
If OBJECT_ID(N'ufn_GetAccountingEndDate',N'IF') is not null
	drop function ufn_GetAccountingEndDate;
Go
Create function [dbo].[ufn_GetAccountingEndDate]()
Returns [DATETIME]
As
Begin
	Return DATEAdd(millisecond, -2, Convert(datetime,'20040701',112)); -- 112 is used for date style code in the convert function to avoid confusing months and days. It means yyyymmdd.
End;

-- Execute the inline table valued function 'IF' ufn_GetAccountingEndDate()
Select  dbo.ufn_GetAccountingEndDate() As [Accounting End Date];

-- modify the above function to get the end of a new accounting end date
Alter function [dbo].[ufn_GetAccountingEndDate]() returns [datetime]
as
begin
	Return DATEAdd(millisecond, -2, Convert(datetime,'20260521',112));
end;

-- ---------------------------------------------------------------------------
-- Demonstrate working the use of partition by and over clause with aggregate function
-- ---------------------------------------------------------------------------
Select S.SalesOrderID [Sales Order ID], S.ProductID [Product ID], S.OrderQty 'Order Quantity',
SUM(S.orderqty) over (Partition by s.salesorderid) as [Total],
MAX(S.orderqty) over (Partition by s.salesorderid) as [Maximum Order Quantity]
from AdventureWorks2025.Sales.SalesOrderDetail S
Where s.ProductID in (773,776)
order by [Product ID];

-- Retrieve the CustomerID, and storeID for all customers in the AD2025.Sales.Customer table and 
-- Rank the Customers based on CustomerID in descending order. This is useful in identifying the relative
-- order of customers by store or by person association.
Select c.CustomerID, C.storeid,
Rank() over (order by c.storeid desc) as [Rank All],
Rank() over (partition by c.personid order by c.customerid desc) as [Customer Rank]
from AdventureWorks2025.Sales.Customer as C

-- Retrieve the productID, shelf and quantity information for each product in the AD2025.production.productinventory table, calculate a [Running Quantitu] using SUM() window function and give a running total of the inventory quantity per product across locations
Select P.ProductID, P.shelf, P.Quantity,
SUM(P.Quantity) over (Partition by P.productid 
order by P.LocationID rows between unbounded preceding and current row) as [Running Quantity]
From AdventureWorks2025.Production.ProductInventory P;

-- Retrieve/get names, postal codes and SalesYTD for salespeople with non-zero (0) sales and valid territories. This helps in analysing salespeople by geographic area(postal code) and performance tier. 
SELECT P.FirstName, P.LastName, ROW_NUMBER() OVER (ORDER BY A.PostalCode) AS [Row Number],
 NTILE(4) OVER (ORDER BY A.PostalCode) AS [NTILE], S.SalesYTD, A.PostalCode
FROM AdventureWorks2025.Sales.SalesPerson AS S
JOIN AdventureWorks2025.Person.Person AS P
 ON S.BusinessEntityID = P.BusinessEntityID
JOIN AdventureWorks2025.Person.BusinessEntityAddress AS BEA
 ON P.BusinessEntityID = BEA.BusinessEntityID
JOIN AdventureWorks2025.Person.Address AS A
 ON BEA.AddressID = A.AddressID
WHERE S.TerritoryID IS NOT NULL AND S.SalesYTD <> 0;

-- ---------------------------------------------------------------------------
-- Demonstrate working the use of various 'offset' functions
-- ---------------------------------------------------------------------------
-- Create a test table
Create table Test
(
	ColDateTimeOffset datetimeoffset
);

-- Add/insert a record/row in the test table
insert into Test
values
('1998-09-20 07:45:50.71345 -5:00');

-- Get the time in a zone -8 hrs
Select SWITCHOFFSET(coldatetimeoffset,'-08:00') as '-3 hours Offset'
from test;

-- Demonstrate the use of datetimeoffsetfrompart() function
Select DATETIMEOFFSETFROMPARTS(2020,12,31,14,23,23,0,12,0,7) as 'Past Date';
Select DATETIMEOFFSETFROMPARTS(2026,05,22,11,41,23,0,3,0,7) as 'Current Date';

-- Demonstrate the use of different formats used by the system date & time functions
Select SYSDATETIME() as [System Date & Time],
SYSDATETIMEOFFSET() as [System Date & Time Offset],
SYSUTCDATETIME() as [System UTC Date & Time];

-- ---------------------------------------------------------------------------
-- Demonstrate working the use of the lead() & first_value() functions
-- ---------------------------------------------------------------------------
Select BusinessEntityID, YEAR(quotadate) as [Quota Year],
SalesQuota as 'New Quota',
LEAD(Salesquota,1,0) over (order by year(quotadate)) as [Future Quota]
from AdventureWorks2025.Sales.SalesPersonQuotaHistory
where BusinessEntityID = 275 and YEAR(Quotadate) in (2022,2023); -- AD2022 (2012,2013)

-- Demostrate the user of the First_value() function
select Name,ListPrice,
FIRST_VALUE(Name) over(order by listprice asc) as LessExpensive
from AdventureWorks2025.Production.Product
where ProductSubcategoryID = 37;