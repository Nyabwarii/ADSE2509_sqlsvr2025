/* This session covers working with views, stored procedures and querying database metadata. */
 
<<<<<<< HEAD
-- Switch to the customer database
use Cust_db_adse2509;
 
-- ---------------------------------------------------------------------------
-- Demonstrate creating, modifying and deleting views
-- ---------------------------------------------------------------------------
-- Create a view to display the details from the Production.Product table in the AD2025 DB
create view vwProductInfo as
Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
SafetyStockLevel as [Safety Stock Level]
from AdventureWorks2025.Production.Product;
 
-- Display the records returned by the ProductInfo view
Select * from vwProductInfo;
 
-- Get all products with lock from the ProductInfo view
select [Product Name]
from vwProductInfo
where [Product Name] like '%Lock%';
 
-- Create a view using a join to get data from multiple tables
-- Create a view to display the personal detials of employees using data from the HR.Employee table and Person.Person table in the AD2025 DB
Create view vwPersonDetails as
Select P.Title, P.FirstName [First Name], P.MiddleName [Middle Name], P.LastName [Last Name],
E.JobTitle [Job Title], YEAR(GetDate()) - YEAR(E.Birthdate) as [Employee Age], e.Gender
From AdventureWorks2025.Person.Person P -- Person table alias
join AdventureWorks2025.HumanResources.Employee E -- Employee table alias
on P.BusinessEntityID = E.BusinessEntityID;
 
-- Display all the employee's personal details from the PersonDetails view
Select * from vwPersonDetails;
 
-- Recreate the above view but replace all null values in the title and middlename columns with an empty string using coalesce function.
Create view vwEmpDetails1 as
Select Coalesce(P.Title,'') [Title], P.FirstName [First Name], Coalesce(P.MiddleName,'') [Middle Name], P.LastName [Last Name],
E.JobTitle [Job Title], YEAR(GetDate()) - YEAR(E.Birthdate) as [Employee Age], e.Gender
From AdventureWorks2025.Person.Person P -- Person table alias
join AdventureWorks2025.HumanResources.Employee E -- Employee table alias
on P.BusinessEntityID = E.BusinessEntityID;
 
-- Display all the employee's personal details from the EmpDetails view
Select * from vwEmpDetails1;
 
-- Create tables to be used as the base tables for the employee details view
create table Employee_Personal_Details
(
	EmpID int not null primary key,
	FirstName nvarchar(30) not null,
	LastName nvarchar(30) not null,
	Address nvarchar(30)
);
 
Create table Employee_Salary_Details
(
	EmpID int not null Primary Key,
	Designation nvarchar(30) not null,
	Salary int not null
	Foreign key (EmpID) references Employee_Personal_Details(EmpID)
);
 
-- Insert records in the employee personal detials table and salary details table
insert into dbo.Employee_Personal_Details
values
(1, 'Jack', 'Wilson', '24, Park Ave.'),
(2, 'Susan', 'Andrews', '12, Hill Road'),
(3, 'Jack', 'Wilson', '24, Park Ave.');
 
insert into dbo.Employee_Salary_Details
values
(1, 'Accountant', 8000),
(2, 'Reviewer', 12000),
(3, 'Admin', 12500);
 
-- confirm above record insertions
select * from dbo.Employee_Personal_Details;
select * from dbo.Employee_Salary_Details;
 
-- Create a view to display the employee's personal and salary details
create view vwEmpDetails as
Select PD.EmpID [Employee ID], PD.FirstName, PD.LastName, SD.Designation, SD.Salary
from Employee_Personal_Details PD
join Employee_Salary_Details SD
on PD.EmpID = SD.EmpID;
 
-- Display the data returned by the employee details view
Select * from vwEmpDetails;
 
-- Try to insert the details of a new employee using the Employee details view
insert into vwEmpDetails
values
(2,'Jack','Wilson','Software Developer',160000); -- will not work as it gets its data from multiple base tables.
 
-- Create a view that will allow us to enter rows/records/tuples in the employee salary details table
create view vwEmp_Details as
Select EmpID, FirstName, LastName, Address
from Employee_Personal_Details;
 
-- Get/Display the records returned by the above view
Select * from vwEmp_Details;
 
-- Add/insert Jack Wilson's details using the 'vwEmp_details' view
insert into vwEmp_Details
values
(4,'Jack','Wilson','New York');
 
-- Create a product details table and its corresponding view that will be used to modify/update records in the table
Create table Product_Details  
(
	ProductID int not null,
	ProductName nvarchar(35) not null,
	Rate money not null
);
 
-- Insert/add records into the above table
insert into Product_Details
values
(5,'DVD Writer',2250.00),
(4,'DVD Writer',1250.00),
(6,'DVD Writer',1250.00),
(2,'External Hard Drive',4250.00),
(3,'External Hard Drive',4250.00);
 
-- Confirm table creation and record insertion
select * from Product_Details;
 
-- TODO: Create a view called 'vwProduct_Details' to display all columns from the 'Product_Details' table. Send your statements via private chat on Teams
create view vwProduct_Details as
select ProductID,ProductName,Rate
from Product_Details;
 
-- View all the records returned by the product details view
select * from vwProduct_Details;
 
-- Update the prices of all DVD writers to 3k
update vwProduct_Details
set Rate = 3000
where ProductName like 'DVD Writer';
 
 
-- Modify the product details table to add a description column
alter table dbo.product_details
add [Description] nvarchar(MAX); -- Description in [] since its a keyword
 
=======
  --Switch to the customer database
 use Adan_adse_2509_custdb;

 --Demonstrate creating, modifying and deleting views

 --Create a view to display the details from the Production.Product table in the AD2025 DB
 -- Note: Fixed alias for [name] to match the SELECT in the next step
 Create view vwProductInfo as
 Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
 SafetyStockLevel as [Safety Stock Level]
 FROM AdventureWorks2022.Production.Product;
 GO

 -- Display the records returned by the Product view
 -- Note: Removed redundant FROM clause and fixed column reference
 Select * 
 from vwProductInfo
 where [Product Name] like '%Lock%';

 --Create a view using a join to get data from multiple tables
 --Create a view to display the personal details of employees using data from the HR.Employee table and Person.Person table in AD2025
 Create view vwPersonalDetails as
 Select P.Title, P.FirstName [First Name], P.MiddleName [Middle Name], P.LastName [Last Name],
 E.JobTitle [Job Title], Year(GetDate()) - Year(E.BirthDate) as [Employee Age], e.Gender
 From AdventureWorks2022.Person.Person P -- Person table alias
 join AdventureWorks2022.HumanResources.Employee E -- Fixed: Added missing dot and ON clause
 on P.BusinessEntityID = E.BusinessEntityID;
 GO

 -- Display all the employees personal details from the PersonalDetails view
 Select * from vwPersonalDetails;

 --Recreate the above view but replace all null values in the title and middlename columns with an empty string using coalesce function.
 Create view vwEmpDetails as
 Select Coalesce(P.Title, '') as [Title], P.FirstName [First Name], Coalesce(P.MiddleName, '') [Middle Name], P.LastName [Last Name],
 E.JobTitle [Job Title], Year(GetDate()) - Year(E.BirthDate) as [Employee Age], e.Gender
 From AdventureWorks2025.Person.Person P -- Person table alias
 join AdventureWorks2025.HumanResources.Employee E -- Fixed: Added missing dot
 on P.BusinessEntityID = E.BusinessEntityID;
 GO

 --Display all the employee personal details from the EmpDetails view
 -- Note: Fixed view name to match creation
 Select * from vwEmpDetails;

 use Adan_adse_2509_custdb;
 -- create tables to ;be used as the base tables for the employeee detsails view 
 create table Employee_Personal_Deteails
 (
     EmpID int not null primary key,
	 FirstName nvarchar(30) not null,
	 LastName nvarchar (30),
	 Address nvarchar(30)
	 );
	 create table Employee_Salary_Details
	 (    
	   EmpID int not null primary key,
	   Designation nvarchar(30) not null,
	   Salary int not null,
	   Foreign Key(EmpID) references Employee_Personal_Deteails
	);
insert into dbo.Employee_Personal_Deteails
values
(1,'Jack','Wilson','24, Park Ave.'),
(2,'Susan','Andrews','12, Hill Road.'),
(3,'Jack','Wilson','24, Park Ave.');

insert into dbo.Employee_Salary_Details
values
(1,'Accountant', 8000),
(2,'Reviewer', 12000),
(3,'Admin', 12500);

select * from dbo.Employee_Personal_Deteails
select * from dbo.Employee_Salary_Details

 -- Create a view to display the employee's personal and salary details
 create view vwEmpDetails as
 Select PD.EmpID [Employee ID], PD.FirstName, PD.LastName, SD.Designation, SD.Salary
 from Employee_Personal_Details PD
 join Employee_Salary_Details SD
 on PD.EmpID = SD.EmpID;

 -- Display the data returned by the employee details view
 Select * from vwEmpDetails;

 -- Try to insert the details of a new employee using the Employee details view
 Insert into vwEmpDetails
 values
 (2, 'Jack', 'Wilson', 'Software Developer', 160000); -- will not work as it gets its data from
   multiple base tables.

create view vwEmp_Details as 
select EmpID, FirstName, LastName, Address
from  Employee_Personal_Deteails;

select * from vwEmp_Details;
--Add Jack Wilson details using the Emp_Details  view
insert into vwEmp_Details
values 
(4,'Jack','Wilson','New York');

--create a product deatails table and its corresponding view tha twill be used to modify records int the table
create table Product_Details -- tbl in some companies
(
ProductID int not null,
ProductName nvarchar (35) not null,
Rate money not null
);

insert into Product_Details
values 
(5,'DVD Writer', 2250),
(6,'DVD Writer', 1250),
(7,'DVD Writer', 1250);


select * from  Product_Details;

Create view vwProduct_Details as 
select ProductID, ProductName, Rate
from Product_Details;

select * from vwProduct_Details;

--update the price the priv eof dvd writers to 3k
update vwProduct_Details
set Rate = 3000
where ProductName like 'DVD Writer';

--modify the product details tagleto add a description column 
alter table dbo.Product_Details
add [Description] nvarchar(MAX);

>>>>>>> 772cbe4 (Initial commit)
-- Add/insert more records into the product_details table
Insert into Product_Details
values
(1, 'Hard Disk Drive', 3750,'Internal 120 GB'),
(7,	'Portable Disk Drive',5580,'Internal 500 GB'),
(8,	'Hard Disk Drive',5580,'Internal 500 GB'),
(9,	'Hard Disk Drive',3750,'Internal 120 GB'),
(10,'Portable Disk Drive',3750,'Internal 500 GB');
<<<<<<< HEAD
 
-- Display all the records from the product_details table
Select * from Product_Details;
 
-- Modify/alter the product_details view to display the description column
alter view vwProduct_Details as
select ProductID,ProductName,Rate, [Description]
from Product_Details;
 
-- Correct the description of portable hard drives from internal to external hard drives
update vwProduct_Details
set [Description] .write(N'Ex',0,2)
where ProductName like 'Portable Disk Drive';
 
-- Create a customer details table
Create table Customer_Details
(
	CustID nvarchar(7) not null primary key,
	AccNo int identity(1,1) not null,
	AccName nvarchar(20) not null,
	[Date of Birth] date not null,
	City nvarchar(25) not null
);
 
-- Add records to the customer_details table
Insert into dbo.Customer_Details
(CustID,AccName,[Date of Birth], City)
values
('C0001','Jane','1980-02-02', 'Topeka'),
('C0002','Haris','1978-12-15', 'Lansing'),
('C0003','Pitts','1985-11-10', 'Columbus'),
('C0004','Monaliza','1980-11-12', 'Topeka');
 
-- Display the details from the Customer details table
Select * from dbo.Customer_Details;
 
-- Create a customer details view
Create view vwCustDetails as
Select CustID, AccNo [Account Number], AccName [Account Name],[Date of Birth], City
from Customer_Details
 
-- Display the records returned by the customer details view
select * from vwCustDetails;
 
-- Delete Monaliza's details using the customer details view
delete from vwCustDetails
where CustID like 'C0004';
 
-- Create a view that will be deleted
create view vw2Delete as
Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
SafetyStockLevel as [Safety Stock Level]
from AdventureWorks2025.Production.Product;
 
-- display the records returned by the vw2Delete view
select * from vw2Delete;
 
-- Remove/delete the vw2Delete view
Drop view vw2Delete;
 
-- View the statements that were used to create the customer details view
execute sp_helptext vwCustDetails;
 
-- View the statements that were used to create the Product information view
execute sp_helptext vwProductInfo;
 
-- Create a view to display the average price(rate) of products using the inbuilt function 'AVG()'
create view vwAvgPrice as
select ProductName, AVG(rate) as [Average Price]
from dbo.Product_Details
group by ProductName;
 
-- display the details returned by the above view
Select * from vwAvgPrice;
 
-- Create a view with the check option to prevent entry of safety stock levels above 1000
create view vwProductInfomation as
Select Productid as [Product ID], productnumber [Product Number], [name] [Product Name], safetystocklevel [Safety Stock Level], ReorderPoint [Re-order Point]
from AdventureWorks2025.Production.Product
where safetyStocklevel <= 1000
with check option;
 
-- View the records returned by the above view
select * from vwProductInfomation;
 
-- Try to make changes to the 'vwProductInfomation' view that would violate the check constraint
update vwProductInfomation
set [Safety Stock Level] = 2500
where [Product ID] = 321;
 
-- Error msg 4512 NB: will not work because we're using three part name format (db.schema.table). should be (schema.table)
-- For error msg 229 & msg 1088:  the issue is lack of create permissions on the AD2022 or AD2025 DB.
-- For Error msg 550 : Cause is we're violating the check constraint, hence the update fails.
 
-- ---------------------------------------------------------------------------
-- Demonstrate creating, modifying and deleting Stored Procedures
-- ---------------------------------------------------------------------------
-- Demonstrate the working of sp_refreshview Stored procedure(SP/sp)
-- 1. Create a customer table
if OBJECT_ID('Customer') is null
	Create table Customer
	(
		CustID int,
		CustName nvarchar(50),
		Address nvarchar(60)
	);
else
	Print('The ''Customer'' Table already exists and will not be recreated!');
 
-- 2. Create a Customer view
Create view vwCustomer as
select * from Customer;
 
-- 3. Display the records returned by the customer view
Select * from vwCustomer;
 
-- 4. Modify the customer table by adding an age column
Alter table customer
add Age tinyint;
 
-- 5. Use the sp_refreshview stored procedure to refresh the customer view to include the 'age' column
exec sp_refreshview 'vwCustomer';
 
-- Use an extended stored procedure to check if a file exists in the server
exec xp_fileexist 'c:\classfile.txt';
 
-- Use an extended stored procedure to check if the solution file exists in the server
exec xp_fileexist 'J:\classwork\adse_2509\sem1\07_sqlsvr\ADSE2509_SQLSVR2022\ADSE2509_SQLSVR2022\ADSE2509_SQLSVR2022.sln';
 
-- Create a custom/user defined stored procedure
Create procedure uspCustTerritory as
select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
from AdventureWorks2025.Sales.Customer C
join AdventureWorks2025.Sales.SalesTerritory T
on C.TerritoryID = T.TerritoryID;
 
-- Execute the customer territory custom procedure
exec uspCustTerritory;
 
-- View the definition of the statements used to create the customer territory view.
execute sp_helptext 'uspCustTerritory';
 
-- Create a custom/user defined stored procedure that accepts input parameters
create proc uspGetSales
@territory nvarchar(40) -- Input variable to store the name of the sales region/territory
as
select BusinessEntityID,  ST.SalesYTD [Sales Year to Date], ST.SalesLastYear as [Sales Last Year]
from AdventureWorks2025.Sales.SalesPerson SP
join AdventureWorks2025.Sales.SalesTerritory ST
on SP.TerritoryID = ST.TerritoryID
where ST.Name like @territory;
 
-- Get the sales details for the northwest and northeast regions using the get sales custom stored procedure
exec uspGetSales 'NorthWest';
exec uspGetSales 'NorthEast';
 
-- Create a custom/user defined stored procedure that accepts both input and output parameters
create proc uspGetTotalSales
@salesTerritory nvarchar(40), -- Input variable to store the name of the sales region/territory
@sum int output -- return/output variable to hold the total sales for the specified region/territory
as
select @sum = SUM(ST.salesytd)
from AdventureWorks2025.Sales.SalesPerson SP
join AdventureWorks2025.Sales.SalesTerritory ST
on SP.TerritoryID = ST.TerritoryID
where ST.Name like @salesterritory;
 
-- Get and display the total sales for the 'northwest' and 'northeast' regions
Declare @northWestSales money -- Variable to hold the 'northwest' total sales
exec uspGetTotalSales 'NorthWest', @sum = @northWestSales output;
-- Display the sales for the 'Northwest' region
print 'The year-to-date total for the ''NorthWest'' region is Kes. ' + convert(nvarchar(100),@northWestSales);
 
-- TODO: quick class assignment -> Get and dispay the total sales for the 'northeast' region
 
-- Modify/alter a custom SP to add a new column in the resultset
Alter proc uspGetSales
@territory nvarchar(40) -- Input variable to store the name of the sales region/territory
as
select BusinessEntityID,  ST.SalesYTD [Sales Year to Date], ST.SalesLastYear as [Sales Last Year],
ST.CostYTD as [Cost Year to Date] -- Column added in the modification
from AdventureWorks2025.Sales.SalesPerson SP
join AdventureWorks2025.Sales.SalesTerritory ST
on SP.TerritoryID = ST.TerritoryID
where ST.Name like @territory;
 
-- TODO: Quick assignment 2. Display the statements used to create the uspGetSales custom procedure
 
 
-- Get the sales details for the northwest and northeast regions using the modified get sales custom stored procedure
exec uspGetSales 'NorthWest';
exec uspGetSales 'NorthEast';
 
-- Delete an SP
-- Create a dummy SP that will be deleted
create proc usp2Delete
-- with encryption -- Hides the statements used to create this SP.
as
select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
from AdventureWorks2025.Sales.Customer C
join AdventureWorks2025.Sales.SalesTerritory T
on C.TerritoryID = T.TerritoryID;
 
-- Execute the 2Delete custom procedure
exec usp2Delete;
 
-- Check for dependencies on the 'usp2Delete' custom stored procedure
exec sp_depends 'usp2Delete';
 
-- Remove/delete the 'usp2Delete' custom stored procedure
drop proc usp2Delete;
 
-- Display the statements used to create the uspCustTerritory custom procedure
exec sp_helptext 'uspCustTerritory';
 
-- Modify the 'uspCustTerritory' custom stored procedure to hide(encrypt) the statements that were used to create it.
Alter procedure uspCustTerritory 
with encryption -- Hides the statements used to create this SP.
as
select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
from AdventureWorks2025.Sales.Customer C
join AdventureWorks2025.Sales.SalesTerritory T
on C.TerritoryID = T.TerritoryID;
 
-- Create a nested stored procedure ( an SP that calls other stored procedures)
Create proc uspNestedProcedure as
BEGIN
	exec uspCustTerritory
	execute uspGetSales 'France'
END
 
-- Execute the nested stored procedure
exec uspNestedProcedure;
 
-- ---------------------------------------------------------------------------
-- Querying System Metadata
-- ---------------------------------------------------------------------------
-- Display a list of user tables and their attributes from the system catalog view
Select name, OBJECT_ID, type, type_desc
from sys.tables;
 
-- Display data from the AD2025 DB
select TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
from AdventureWorks2025.INFORMATION_SCHEMA.TABLES;
 
-- Display data from the customer database
select TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
from Cust_db_adse2509.INFORMATION_SCHEMA.TABLES;
 
-- Display the objectid of the products and customer's table
select OBJECT_ID('Products') as [Products Table ObjectID]; -- 658101385
select OBJECT_ID('Customer') as [Customer Table ObjectID]; -- 1938105945
 
-- Display the object names of the objectID 658101385 & 1938105945  table
select OBJECT_Name(658101385) as [Name of ObjectID '658101385'];
select OBJECT_Name(1938105945) as [Name of ObjectID '1938105945'];
 
-- Get the version of the sqlserver in which this script is running on
Select SERVERPROPERTY('productversion') as [SQL Server Version];
 
-- Get the edition of the sqlserver in which this script is running
Select SERVERPROPERTY('edition') as [SQL Server Edition];
 
-- TODO: 3. Display the version and edition of your current sql server with a column titled 'SQL Server and Edition'
 
-- Display a list of the current user connection details from the sys.dm_exec_sessions view
Select SESSION_ID, login_name, login_time, program_name
from sys.dm_exec_sessions
where login_name = 'CUI-LAPTOP\Cui' and is_user_process = 1;
=======

alter view vwProduct_Details
select ProductID, ProductName, Rate, [Description]
from Product_Details;

update vwProduct_Details
set [Description] .write(N'Ex',0,2)
where ProductName like 'Portable Disk Drive';

create table Customer_Details
(
  CustID nvarchar(7) not null primary key,
  AccNo int identity(1,1) not null,
  AccName nvarchar (20)not null,
  [Date of Birth] date not null,
  City nvarchar (25) not null
);

insert into dbo.Customer_Details
(CustID,AccName,[Date of Birth],City)
Values
('C0001','Jane','1980-02-02','Topeka'),
('C0002','Haris','1978-12-15','Lansing'),
('C0003','Pitts','1985-11-10','Columbus'),
('C0004','Monaliza','1980-11-12','Topeka');

select * from dbo.Customer_Details;

create view vwCustDetails as
select CustID, AccNo [Account Number], AccName [Account Name],[Date of Birth],City
from Customer_Details

select * from vwCustDetails;

delete from vwCustDetails
where CustID like 'C0004';

create view vw2Delete as 
Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
 SafetyStockLevel as [Safety Stock Level]
 FROM AdventureWorks2022.Production.Product;

 select * from vw2Delete;

 -- remove/delete the vw2Delete view
 drop view vw2Delete;

 -- view the statements that were used to create the customer details view
 execute sp_helptext vwCustDetails;

 --create a view to display the average price of produvts using the inbuilt AVG()
 create view vwAvgPrice as
 select  ProductName, AVG(Rate)as [Average Price]
 from dbo.Product_Details
 group by ProductName;

 select * from vwAvgPrice;

 create view vwProductInformation as
 select ProductID as [Product ID], productNumber [Product Number], [name] [Product Name], safetystocklevel [Safety Stock Level], ReorderPoint [Reorder Point]
 from AdventureWorks2022.Production.Product
 where safetyStocklevel <= 1000
 with check option;

 select * from vwProductInformation;

 --rey to make changes to the vwProductInformation
 update vwProductInformation
 set [Safety Stock Level] = 2500
 where [Product ID] = 321;

 if OBJECT_ID('Customer')is null
    create table Customer
	(
	  CustID int,
	  CustName nvarchar(50),
	  Address nvarchar(60)
	);
	else
	    print('The ''Customer'' Table already exists and will not be recreated!');
create view vwCustomer as
select *from Customer;

select * from vwCustomer;

alter table Customer
add Age tinyint;

--use the sp_refreshview stored procedure to refresh the custoemr view to include the 'age' column
exec sp_refreshview 'vwCustomer';

exec xp_fileexists 'c:\classfile.txt';

exec xp_fileexists 'C:\Users\a.yusuf\Documents\School Work\adse2509_sqlsvr\ADSE2509_SQLSVR2022.sln';

create procedure uspCustTerritory as
select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
from AdventureWorks2022.Sales.Customer C
join AdventureWorks2022.Sales.SalesTerritory T
on C.TerritoryID = T.TerritoryID;

exec uspCustTerritory;

--view the definition of the statements used to create the customer territory view
 execute sp_helptext uspCustTerritory;

 --create a custom user defined stored procedure that accepts input parameters
 create proc uspGetSales
 @territory nvarchar(40) --input variable to store the name of the region
 as 
 select BusinessEntityID, ST.SalesYTD[Sales Year to Date],ST.SalesLastYear as [Sales Last Year]
 from AdventureWorks2022.Sales.SalesPerson SP
 join AdventureWorks2022.Sales.SalesTerritory ST
 on SP.TerritoryID = ST.TerritoryID
 where ST.Name like @territory;

 --get the sales details for the northwest and northeast regions using the get 
 --sales custom stored procedure
 exec uspGetSales 'NorthWest';
  exec uspGetSales 'NorthEast';

   --create a custom user defined stored procedure that accepts both input and output parameters
 create proc uspGetToTotalSales
 @salesTerritory nvarchar(40), --input variable to store the name of the region
 @sum int output --return variable to hold   the total sals for the spacified region
 as 
 select @sum = SUM(ST.SalesYTD)
 from AdventureWorks2022.Sales.SalesPerson SP
 join AdventureWorks2022.Sales.SalesTerritory ST
 on SP.TerritoryID = ST.TerritoryID
 where ST.Name like @salesTerritory;

 -- get and display the total sales for the 'northwest' and 'northeasst' regions
 Declare @northWestSales money --variable to hold the northwest total sales
 exec uspGetToTotalSales 'northWest', @sum = @northWestSales output;
 --Display the sales for the northwesst region
 print 'The year-to-date total for the ''NorthWest'' region is Kes.' + convert(nvarchar(100),@northWestSales);

 --TO DO - get and display the total sales for the 'northeast' region
 --This is my solution
  Declare @northEastSales money --variable to hold the northeast total sales
  exec uspGetToTotalSales 'northEast', @sum = @northEastSales output;
  --Display the sales for the northEast region
 print 'The year-to-date total for the ''NorthEast'' region is Kes.' + convert(nvarchar(100),@northEastSales);

 --Modify alter a custom SP to add a new column in the result set
 alter proc uspGetSales
 @territory nvarchar(40) --input variable to store the name of the region
 as 
 select BusinessEntityID, ST.SalesYTD[Sales Year to Date],ST.SalesLastYear as [Sales Last Year], ST.CostYTD as [Cost Year to Date]
 from AdventureWorks2022.Sales.SalesPerson SP
 join AdventureWorks2022.Sales.SalesTerritory ST
 on SP.TerritoryID = ST.TerritoryID
 where ST.Name like @territory;

--TODO 2: Display the statements used to create the uspGetSales custom procedure
 --This is my solutions
 execute sp_helptext uspGetSales;

 --get the sales details for the northwest and northeast regions using the modified get
 --sales custom stored procedure
 exec uspGetSales 'NorthWest';
  exec uspGetSales 'NorthEast';

  --Delete SP
  --create a dummy SP 
  create procedure usp2Delete
  with encryption --Hides the statements used to create this SP
  as
  select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
  from AdventureWorks2022.Sales.Customer C
  join AdventureWorks2022.Sales.SalesTerritory T
  on C.TerritoryID = T.TerritoryID;

exec usp2Delete;

--check for dependencies on the usp2delete custom procedure
exec sp_depends 'usp2Delete'

--Remove the usp2Delete custom procedure
drop proc usp2Delete;

--Display the statements used to create the uspCustTerritory custom procedure
exec sp_helptext 'uspCustTerritory';

--modify the uspCustTerritory custom stored Procedure to hide the statements that were used to create it
alter procedure uspCustTerritory
with encryption --Hides the statements used to create this SP 
as
select top 10 C.CustomerID [Customer ID], C.TerritoryID [Territory ID], T.Name as [Territory Name]
from AdventureWorks2022.Sales.Customer C
join AdventureWorks2022.Sales.SalesTerritory T
on C.TerritoryID = T.TerritoryID;


--Create a nestedd stored procedure an SP that calls other stored procedures
create proc uspNestedProcedure as
BEGIN 
   exec uspCustTerritory
   execute uspGetSales 'France'
END

--Execute the nested stored procedure
exec uspNestedProcedure;

-- -------------------------------------------------
-- Querying sSystem Metadata
-- -------------------------------------------------
--Display a list of user tables and their attributes fromt the system catalog view
select name, OBJECT_ID, type, type_desc
from sys.tables;

--Display data from the AD2022DB
select TABLE_CATALOG, TABLE_SCHEMA,  TABLE_NAME, TABLE_TYPE
from AdventureWorks2022.INFORMATION_SCHEMA.TABLES;

--Display data from the Adan_custDB
select TABLE_CATALOG, TABLE_SCHEMA,  TABLE_NAME, TABLE_TYPE
from Adan_adse_2509_custdb.INFORMATION_SCHEMA.TABLES;

--Display the objectid of the products and the customers table
select OBJECT_ID('Products') as [Products Table ObjectID]; --1029578706
select OBJECT_ID('Customer') as [Customer Table ObjectID]; --1525580473

--Display the objectnames of the objectid 1029578706 & 1525580473 table
select OBJECT_Name('1029578706') as [Name of ObjectID '1029578706'];
select OBJECT_Name('1525580473') as [Name of ObjectID '1525580473'];

-- Get the version of the sqlServer in which this script is running on
select SERVERPROPERTY('productversion') as [SQL Server Version];

--Get the edition of the sqlServer in which this script is running on
select SERVERPROPERTY('edition') as [SQL Server Edition];

--TODO 3: Display the version and edition of your current sql server with a column titled 'SQL Server and Edition'
--This is my solution
select SERVERPROPERTY('productversion') + ' - ' + SERVERPROPERTY('edition') as [SQL Server and Edition];

--Display a list of the current user connection details from the sys.dm_exec_sessions view
select SESSION_ID, login_name, login_time, PROGRAM_NAME
from sys.dm_exec_sessions
where login_name = 'EDULINK\t.nyabwari' and is_user_process = 1;
>>>>>>> 772cbe4 (Initial commit)
