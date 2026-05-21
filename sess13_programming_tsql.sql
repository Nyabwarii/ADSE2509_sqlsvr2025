/* Session 13 covers various programming aspects of T-SQL. */

-- Switch to the customer database
use Adan_adse_2509_custdb;

-- -------------------------------------------------
-- Demonstrate working with a batch
-- -------------------------------------------------

--Create a batch
Begin Transaction
     -- Create the ''company table if it doesnt exist
	 if OBJECT_ID('Company') is null
	   create table Company
	   (
	      IDNum int identity(100,5),
		  CompanyName nvarchar(100)
	   );
	else 
	   print 'The "Company" table already exists and will not be recreated'
    -- insert rows to the company table
    Insert into Company
	values
	('A Bike Store'),
	('Progressive Sports'),
	('Modular Cycle Streams'),
	('Advanced Bike Components'),
	('Metropolitan Sports Supple'),
	('Aerobics Exercise Company'),
	('Associated Bikes'),
	('Exemplary Cycles');
	---Display the above companies in ascending order
	select IDNum 'Company ID', CompanyName as 'Name of Company' from Company order by CompanyName
commit; -- rollback

-- -------------------------------------------------
-- Demonstrate working with local variables
-- -------------------------------------------------

--Declare and use a local variable in a select statement
Declare @find nvarchar(30) ='Man%'; -- used to find the last name of person that start with <Man>
select p.FirstName, P.LastName, pp.PhoneNumber
from AdventureWorks2022.Person.Person P
join AdventureWorks2022.Person.PersonPhone PP
on P.BusinessEntityID = PP.BusinessEntityID
where p.LastName like @find;

-- Declare a variable and assign it a value using the set keyword
Declare @myVar nchar(40); --Assigned 'NULL' by default
set @myVar = 'This is a test variable'; -- Assign some text to the variable
select @myVar 'Content of @myVar'; -- Display the contents of @myVar

--use the select keyword to assign a value to a variable
Declare @var1 nvarchar(30);
select @var1 = 'Unnamed Company' --Assignment statement
select @var1 = Name
from AdventureWorks2022.Sales.Store
where BusinessEntityID = 10;

select @var1 'Company Name'; -- Query the name of the store with businessEntityID 10 stored in @var1 variable

-- -------------------------------------------------
-- Demonstrate working with object synonyms
-- -------------------------------------------------
--Create a synonym for the 'Company' table ysing T-SQL code
create synonym [Kampuni] for dbo.Company;

--Display the first 5 products and companies from the products and company tables using their synonyms
select top(5) [name] from Bidhaa;
select top(5) [CompanyName] from Kampuni;