/* This session covers working with views, stored procedures and querying database metadata */

 --Switch to the customer database
 use Cust_db_adse2509;

 --Demonstrate creating, modifying and deleting views

 --Create a view to display the details from the Production.Product table in the AD2025 DB
 -- Note: Fixed alias for [name] to match the SELECT in the next step
 Create view vwProductInfo as
 Select ProductID [Product ID], ProductNumber [Product Number], [name] [Product Name],
 SafetyStockLevel as [Safety Stock Level]
 FROM AdventureWorks2025.Production.Product;
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
 From AdventureWorks2025.Person.Person P -- Person table alias
 join AdventureWorks2025.HumanResources.Employee E -- Fixed: Added missing dot and ON clause
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

 use Cust_db_adse2509;

 --Create tables to be used as the base tables for the employee details view
 create table Employee_Personal_Details(
	EmpID int not null primary key,
	FirstName nvarchar(30) not null,
	LastName nvarchar(30) not null,
	Address nvarchar(30));

 Create table Employee_Salary_Details(
	EmpID int not null Primary key,
	Designation nvarchar(30) not null,
	Salary int not null);

 --Insert records in the employee personal details table and salary details table
 insert into dbo.Employee_Personal_Details
 values(1, 'Jack', 'Wilson', '24, Park Ave'),
 (2, 'Susan', 'Andrews', '12, Hill Road'),
 (3, 'John', 'Doe', '24 Park Ave'); -- Note: Changed duplicate data to distinct for clarity

 insert into dbo.Employee_Salary_Details
 values(1, 'Accountant', 8000),
 (2, 'Reviewer', 12000 ),
 (3, 'Admin',12500);

 -- confirm above record insertions
 select * from dbo.Employee_Personal_Details;
 select * from dbo.Employee_Salary_Details;

 --Create a view to display the employee's salary details 
 create view vwEmpSalaryDetails as
 Select PD.EmpID [EmployeeID], PD.FirstName, PD.LastName, SD.Designation, SD.Salary
 From Employee_Personal_Details PD
 join Employee_Salary_Details SD
 on PD.EmpID = SD.EmpID;

 -- Display the data returned by the employee salary details view
 Select * from vwEmpDetails;

 --Try to insert the details of a new employee using the Employee details view
 insert into vwEmpDetails
 values
 (2, 'Jack', 'Wilson', 'Software Developer', 16000); --will not work as it gets its data from multiple basr tabeles

 --Create a view that will allow us to enter rows/records/tuples into the employee details view
 create view vwEmp_details as
 Select EmpID, FirstName, LastName, Adress
 from Employee_Personal_Details;

 -- Get Display the records returned by the above view
 Select * from vwEmp_details;

 -- Add Jack Wilson's details using the above view
insert into vwEmp_Details
values
(4, 'Jack', 'Wilson', 'New York');


--Create a product details table and its corresponding view that will be used to modify records in the table
Create table Product_Details
(
	ProductID int not null,
	ProductName nvarchar(30) not null,
	Rate money not null)
);

-- Inset into Product_Details values 