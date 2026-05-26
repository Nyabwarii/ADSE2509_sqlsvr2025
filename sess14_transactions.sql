/*Session 1 4covers transactions in sql server*/
CREATE DATABASE Customer_DB_ADSE2509;
GO
--switch to the customer database
Use Customer_DB_ADSE2509

--Display the employess in the Employeedetails table
select* from dbo.EmployeeDetails;

--add the details of anew employee
insert into dbo.EmployeeDetails
values
(106, 'James','Gichuru','1994-06-16', 'Male','Kawangware');

--Begin a transaction to declare James Gichuru details from the employeeDetails table
Declare @transName nvarchar(30) = 'FirstTransaction';
begin transaction @transName;
delete from dbo.EmployeeDetails
where EmpID = 106;

--Begin a transaction to delete James' details from the employeeDetails table
Declare @delsName nvarchar(30) = 'deleteJames';
begin transaction @deleteJames;
delete from dbo.EmployeeDetails
where EmpID = 106;
commit tran; --commit the Transaction

create table ValueTable
(
  [Value] nchar not null
);

 

-- Add/insert values into the ValueTable using explicit transactions
Begin tran
  Insert into dbo.ValueTable
  values
  ('A'),
  ('C'),
  ('N')
  Go
  -- Display the details in the ValueTable
  Select * from dbo.ValueTable
-- Undo the inserts
Rollback tran

--Create a custom store procedure with a savepoint
create proc uspSaveTransExample
@inputCandidateID int
as 
Declare @transCounter int;
set @transCounter = @@TranCount;
if @transCounter > 0 
	Save tran ProcedureSave;
else
	Begin Tran;
		Delete from
		AdventureWorks2022.HumanResources.JobCandidate
		where JobCandidateID = @inputCandidateID;
		if @transCounter = 0
		print 'Transaction successful!'
		commit tran;
		if @transCounter = 1
		print 'Transaction rolled back!'
	Rollback tran ProcedureSave;