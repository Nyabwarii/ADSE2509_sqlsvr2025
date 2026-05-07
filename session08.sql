/* SESSION 08: DATA RETRIEVAL & TRANSFORMATION
*/

-- ==========================================
-- 1. SELECT WITHOUT FROM (STRING & MATH)
-- ==========================================

-- String manipulation using built-in functions
SELECT LEFT('International', 7) AS [First 7 characters];
SELECT RIGHT('International', 7) AS [Last 7 characters];

-- Basic arithmetic
SELECT (7 + 5) AS [Sum of 7 and 5];


-- ==========================================
-- 2. BASIC RETRIEVAL & DATABASE CONTEXT
-- ==========================================

-- Set the database context
USE AdventureWorks2025;

-- Select all columns from Employee (Different ways to reference)
SELECT * FROM HumanResources.Employee;
SELECT * FROM AdventureWorks2025.HumanResources.Employee;

-- Specific column selection
SELECT LocationID, CostRate FROM Production.Location;


-- ==========================================
-- 3. ALIASING, CONCATENATION & CALCULATIONS
-- ==========================================

-- Standard selection
SELECT [Name], CountryRegionCode FROM Sales.SalesTerritory;

-- Concatenation with constants (The ':' and '-->' formatting)
SELECT [Name] + ':' + [CountryRegionCode] + '-->' + [Group] AS [Country Region and Code]
FROM Sales.SalesTerritory;

-- Simple Aliasing
SELECT ModifiedDate AS [ChangedDate] FROM Person.Person;

-- Mathematical calculations (10% Discount)
SELECT StandardCost, (StandardCost * 0.1) AS [Discount Amount]
FROM Production.ProductCostHistory;


-- ==========================================
-- 4. FILTERING & PATTERN MATCHING (WHERE)
-- ==========================================

-- Exact Date filtering
SELECT * FROM Production.ProductCostHistory
WHERE EndDate = '4/15/2013 12:00:00 AM';

-- TODO 01: Filter by City
SELECT * FROM Person.Address
WHERE City = 'Bothell';

-- TODO 02: Complex Filtering (OR)
SELECT * FROM Person.BusinessEntityAddress
WHERE AddressID > 900 OR AddressTypeID = 5;

-- Wildcards: Title matching 'Mr.' or 'Ms.'
SELECT Title, FirstName, LastName
FROM Person.Person
WHERE Title LIKE 'M[rs].';

-- Wildcards: Last name ending in 'en'
SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE LastName LIKE '%en';

-- Wildcards: Excluding specific characters
SELECT * FROM Sales.CurrencyRate
WHERE CurrencyCode LIKE 'v[^au]%';


-- ==========================================
-- 5. RANKING & AGGREGATIONS
-- ==========================================

-- Top 5 Highest Distinct Costs (Descending)
SELECT DISTINCT TOP 5 StandardCost AS [Standard Cost]
FROM Production.ProductCostHistory
ORDER BY [Standard Cost] DESC;

-- Top 5 Lowest Distinct Costs (Ascending)
SELECT DISTINCT TOP 5 StandardCost AS [Standard Cost]
FROM Production.ProductCostHistory
ORDER BY [Standard Cost] ASC;

-- Grouping: Resource hours per WorkOrder
SELECT WorkOrderID, SUM(ActualResourceHrs) AS [Hours Per Order]
FROM Production.WorkOrderRouting
GROUP BY WorkOrderID
ORDER BY [Hours Per Order] DESC;


-- ==========================================
-- 6. DATA TRANSFORMATION (SELECT INTO)
-- ==========================================

-- Create a new table 'ProductName' in a secondary database
-- Note: Replace 'Cost_db_name' with your actual secondary DB name if different
SELECT ProductID, Name 
INTO Cost_db_name.dbo.ProductName 
FROM AdventureWorks2025.Production.Product;

-- Verify the result
SELECT * FROM Cost_db_name.dbo.ProductName;

SELECT * FROM Person.Address
WHERE City = 'Bothell';

SELECT * FROM Person.BusinessEntityAddress
WHERE AddressID > 900 
   OR AddressTypeID = 5;

use Cust_db_adse2509

--Create a Person schema in the Customer Database
Create schema Person;

--Create the PhoneBilling table in Person Schema
Create table Person.PhoneBilling
(
Bill_ID int Primary Key,
MobileNumber bigint unique,
CallDetails XML
);

--Add a record into the PhoneBilling table in the Person Schema
Insert into Person.PhoneBilling
values
(100, 9833276605, '<info>call>Local</call><duration>45 Minutes</duration><charges>200</charges></info>');
--Display the call details from the PhoneBilling table in the Person schema
Select calldetails from Person.PhoneBilling;

--Declare and display the contents of an xml variable
Declare @xmlVar xml
set @xmlVar = '<Employee name = "Ciku"/>';
select @xmlVar as 'Contents of xml variable "xmlVar"'

--Create and register an XML schema
Create XML SCHEMA COLLECTION CricketSchemaCollection

--Create a CricetTeam table wih an XML type column and specify the above schema will be used to validate the column
Create table CricketTeam
(
TeamID int identity not null,
TeamInfo xml(CricketSchemaCollection)
);

--Insert/add data to the CricketTeam table
insert into CricketTeam (TeamInfo)
value
(
	'<MatchDetails>
	<Team country="Australia" score="355"></Team>
	<Team country="Zimbabwe" score="475"></Team>
	<Team country="England" score="200"></Team>
	</MatchDetails>
	'
);


--Create a typed xml variables using the "CreatSchemaCollection" schema
Declare @team xml(CricketSchemaCollection)
Set @team = '<MatchDetails><Team country="Australia" score="355"></Team></MatchDetails'
Select @team as 'Team';

--Demonstrate the use of exist() method
Select TeamID
from CricketTeam
where TeamInfo.exist('/MatchDetails/Team') = 1;

--Demonstrate the use of query() method
Select TeamInfo.query('/MatchDetails/Team') As info
from CricketTeam;

--Demonstrate the use of value() method
Select TeamInfo.value('/MatchDetails/Team/@score[1]', 'varchar(20)') as 'Score'
from CricketTeam
where TeamID = 1;




























	-- Create and register an XML schema
	CREATE XML SCHEMA COLLECTION CricketSchemaCollection
	AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" >
	<xsd:element name="MatchDetails">
	<xsd:complexType>
	<xsd:complexContent>
	<xsd:restriction base="xsd:anyType">
	<xsd:sequence>
	<xsd:element name="Team" minOccurs="0" maxOccurs="unbounded">
	<xsd:complexType>
	<xsd:complexContent>
	<xsd:restriction base="xsd:anyType">
	<xsd:sequence />
	<xsd:attribute name="country" type="xsd:string" />
	<xsd:attribute name="score" type="xsd:string" />
	</xsd:restriction>
	</xsd:complexContent>
	</xsd:complexType>
	</xsd:element>
	</xsd:sequence>
	</xsd:restriction>
	</xsd:complexContent>
	</xsd:complexType>
	</xsd:element>
	</xsd:schema>';
	