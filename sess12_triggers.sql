/* Session 12 covers database and table triggers, i.e., how to create, modify, and delete DB & table triggers. */

-- Switch to the customer database
use Cust_db_adse2509;

-- Create the employee table 'tblEmployee' if it doesn't exist
if not exists
(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblEmployee')
Begin
	CREATE Table tblEmployee
	(
		EmpID int not null primary key,
		Names nvarchar (150) not null,
		Salary decimal(10,2) not null,
		HomeTown nvarchar (80) not null
	)
End;

-- Insert/add records to the 'tblEmployee' table
insert into dbo.tblEmployee
values
(1, 'Rashley Mumbua', 135000.00,'Ahero'),
(2, 'Moses Mapena', 20000.00,'Arusha'),
(3, 'Francis Xavier', 70000.00,'Sportsview'),
(4, 'Valentine Miranda', 100000.00,'Juja'),
(5, 'Alexander Ntumba', 115000.00,'Westlands'),
(6, 'Mohamed Said', 120000.00,'Eastleigh'),
(7, 'Yonatan Teka', 300000.00,'Mahutini'),
(8, 'Zakaria Yussuf', 200000.00,'South B'),
(9, 'Mathew Muindi', 250000.00,'Kilimani');

-- Confirm the insertion of the above records
Select * from tblEmployee;

-- Delete the 1st record from the 'tblEmployee' table
delete 
from tblEmployee
where EmpID = 1;

-- Create an insert trigger on the 'tblEmployee' table to prevent insert of salary amounts less 15000
Create trigger trg_minSalary
on dbo.tblEmployee
for insert
as 
if(select salary from inserted) < 15000
Begin
	Print 'Sorry, you cannot pay employees less than 15000 as it''s below the minimum statutory wage!'
	rollback
End;


-- Insert a record that will violate the minimum wage statutory law
insert into dbo.tblEmployee
values
(1, 'Nyanjui Arthur' ,13500.00,'Limuru');

-- Create an employeedetails table if it doesn't exist
if OBJECT_ID('EmployeeDetails','u') is null
	Create table EmployeeDetails
	(
		EmpID int not null primary key,
		FirstName nvarchar(20) not null,
		LastName nvarchar(20) not null,
		DateOfBirth date not null,
		Gender nvarchar(6) not null,
		City nvarchar(50) not null
	)
else
	Print('The "EmployeeDetails" table already exists and will not be recreated!')

-- Add/insert records into the 'EmployeeDetails' table
insert into dbo.EmployeeDetails
values
(101,'Andrew','Waller','1994-03-22','Male','Boston'),
(102,'Aj','Sties','1992-02-14','Female','Liverpool'),
(103,'Sophia','Broderich','1996-05-18','Female','Boston'),
(104,'Shawn','Roderichs','1986-07-17','Male','Texas');

-- Add your details as record 105
insert into dbo.EmployeeDetails
values
(105, 'Nyanjui', 'Arthur' ,'2010-03-22','Male','Limuru');

-- Confirm the above insertion
Select * from dbo.EmployeeDetails;

-- Add/insert more records into the employeedetails table
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (1, 'Edin', 'Sangwin', '1978-03-10', 'Female', 'Licuan');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (2, 'Karen', 'Ivashnyov', '1979-07-30', 'Female', 'Santa Cruz');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (3, 'Briggs', 'Dameisele', '1971-03-06', 'Male', 'San Mateo');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (4, 'Janina', 'Van Dijk', '1986-07-25', 'Female', 'Fukuma');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (5, 'Vivyanne', 'Haggett', '1981-05-16', 'Female', 'Mora');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (6, 'Clerc', 'Kingcott', '1998-07-28', 'Male', 'Ciudad Bolivia');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (7, 'Melessa', 'Whitby', '1992-06-05', 'Female', 'Ushi');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (8, 'Siward', 'Bugden', '1983-04-20', 'Male', 'Hörby');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (9, 'Brigida', 'Drummond', '1988-11-18', 'Female', 'Liangzeng');
insert into EmployeeDetails (EmpID, FirstName, LastName, DateOfBirth, Gender, City) values (10, 'Saxe', 'Ethington', '1977-10-13', 'Male', 'Frutal');

-- Create a trigger that will prevent entering birthdates greater than today's date.
Create trigger trg_CheckBirthDate
on dbo.EmployeeDetails
for update as
if (Select dateofbirth from inserted) > GETDATE()
	Begin
		print 'Sorry, the date of birth cannot be after today''s date!'
		rollback
	End;

-- Try to update Clerc Kingcott's birth date to 24th August 2032
update dbo.employeeDetails
set dateofbirth = '2032-08-24'
where empid = 6;

-- Create the studentdetails table if it doesn't exist
if not exists
(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'StudentDetails')
Begin
	CREATE Table StudentDetails
	(
		ID int not null primary key,
		Name nvarchar (50) not null,
		Age int,
		Email varchar(100)
	)
End;

-- Insert/add records to the 'tblEmployee' table
insert into dbo.StudentDetails (ID,Name,Age,Email)
values
(1,'Abigail',20,'abigail@edulink.ac.ke'),
(2,'Brian',22,'brian@edulink.ac.ke'),
(3,'Charlie',21,'charlie@edulink.ac.ke'),
(4,'David',20,'david@edulink.ac.ke'),
(5,'Eve',20,'eve@edulink.ac.ke');

-- Confirm the above insertion
Select * from StudentDetails;

-- Create a table to store deleted student details
Create table deleted_students
(
	ID int primary key,
	deleted_name VARCHAR(50),
	deleted_age INT,
	deleted_email VARCHAR(100),
	deleted_date DATETIME default GETDATE()
);

-- Create trigger for delete operations on the 'StudentDetails' table
Create trigger trg_delete_StudentDetails
on dbo.StudentDetails
for delete as
Begin
	Set nocount on;

	Insert into 
	deleted_students(id,deleted_name,deleted_age,deleted_email)
	Select id, name, age,email
	from deleted;


	-- Variable to be used in the delete trigger
	declare @deletedID int = (select id from deleted)
	declare @deletedName nvarchar(50) = (select name from deleted)

	-- Display the ID annd name of the student whose details were deleted
	print 'The details of student id ' + convert(nvarchar(30), @deletedid) + ' ' + @deletedName + ', have been deleted from the studentdetails table!'

	Set nocount off;
End;

-- Delete Charlie's details from the studentdetails table
Delete from StudentDetails
where id = 3;

-- Create an after trigger for the employee details table
Create trigger trgCheckEmpDelete on EmployeeDetails
after delete as
Begin
	declare @num int; -- Local variable to hold the number of deleted records
	select @num = Count(*) from deleted
	print 'The number of employee(s) fired is ' + convert(nchar,@num)
End;

-- Relieve some employees of their duties
delete from dbo.EmployeeDetails
where EmpID >= 6 and EmpID < 10;

-- View the definition of the 'trgCheckEmpDelete' trigger
exec sp_helptext 'trgCheckEmpDelete';

-- Demonstrate creating an encrypted trigger and deleting it
Create trigger trg2Delete on EmployeeDetails
with encryption
after delete as
Begin
	declare @num int; -- Local variable to hold the number of deleted records
	select @num = Count(*) from deleted
	print 'The number of employee(s) fired is ' + convert(nchar,@num)
End;

-- View the definition of the trg2Delete trigger
exec sp_helptext 'trg2Delete';

-- Drop the 'trg2Delete' trigger
Drop trigger trg2Delete;

-- Create a DDL trigger that will prevent the deletion or modification of database tables
Create trigger trgSecure
on Database -- Created on our Customer database
with encryption
for drop_table, alter_table as
Begin
	Print 'Sorry, you cannot delete or modify this table until you disable/delete the trgSecure trigger!';
	rollback;
End;

-- Create a dummy table and try to delete it
Create table tblDummy
(
	DummyID int primary key,
	Dummyname VARCHAR(50),
	Dummyage INT,
	Dummyemail VARCHAR(100)
);

-- Try to remove/drop the 'tblDummy' table from the customer database
drop table tblDummy;

-- Disable the Database DDL 'trgSecure' trigger to allows us to delete the 'tblDummy' table
disable trigger trgSecure on database;

-- Enable the Database DDL 'trgSecure' trigger to prevent table modification and deletion
Enable trigger trgSecure on database;