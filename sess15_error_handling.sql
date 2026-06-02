/* Session 15 covers handling errors or exceptions in T-SQL scripts. */

--switch to the customer database
Use Customer_DB_ADSE2509

-- Switch to the customer database
declare @num int
select @num = 217 / 0; 
select @num;

-- Handle the above error using a try...catch block to handle division by zero '0' error and display error information
begin try
  declare @quotient int = 217 / 0; 
  select @quotient;
end try
begin catch
  Select
  ERROR_NUMBER() as 'Error Number',
  ERROR_SEVERITY() as 'Error Severity',
  ERROR_PROCEDURE() as 'Error Procedure',
  ERROR_STATE() as 'Error State',
  ERROR_MESSAGE() as 'Error Message',
  ERROR_LINE() as 'Error Line';
  -- Rollback Transaction
  If @@TRANCOUNT > 0
    rollback transaction
  Print 'Error encountered, you cannot divide by zero. Please change the denominator to a non-zero value.'
end catch

-- Practical use of try...catch and error functions in a transaction
Begin transaction
  begin try
    delete from AdventureWorks2022.Production.Product
    where ProductID = 980;
  end try
  begin catch
    select 
      ERROR_NUMBER() as 'Error Number', -- Display the error number
      ERROR_SEVERITY() as 'Error Severity', -- Display the error's severity
      ERROR_PROCEDURE() as 'Error Procedure', -- Display where the error occured
      ERROR_STATE() as 'Error State', -- Display the error state
      ERROR_MESSAGE() as 'Error Message', -- Display a preset/default error message
      ERROR_LINE() as 'Error Line'; -- Display the line where the error occured
      -- Check the content of the trancount(Transaction count) global variable
      -- and rollback any changes made when it's > 0 as the transaction failed.
      If @@TRANCOUNT > 0
        rollback transaction
      Print 'Error encountered, transaction rolled back.'
  end catch

-- Demonstrate the user of @@Error to check for constraint violation
begin try
	update AdventureWorks2022.HumanResources.EmployeePayHistory
	set PayFrequency = 4
	where BusinessEntityID = 1;
end try
begin catch
	if @@ERROR = 547
		Print 'Check constraint violation has occured!'
	else
		Print 'Sorry you don''t have permission to update this table'
end catch
	-- Persist the changes when @@TRANCOUNT > 0
	if (@@TRANCOUNT > 0)
		commit transaction

-- Try to get/fetch data from a non-existent table and display the error number and message
Begin try
  exec sp_executesql N'Select * from dbo.nonexistent;'; -- execute sql statement using DSQL
end try
begin catch
  -- Display the error number and message
  Select
  ERROR_NUMBER() as [Error Number],
  ERROR_MESSAGE() as [Error Message]
end catch;

-- Show how to display the error message for the above scenario without using dynamic sql
-- Check if the user defined procedure usp_Example exists and drop it,
-- then recreate it
if OBJECT_ID('usp_Example1','P') is not null
	drop proc usp_Example1;
Go
create proc usp_Example1
as
select * from dbo.nonexistent;
 
Begin try
	exec usp_Example1;
end try
begin catch
	--displaying the error number and message
	select 
	ERROR_NUMBER() as [Error Number],
	ERROR_SEVERITY() As 'Error Severity',
	ERROR_MESSAGE() as [Error Message]
end catch;

-- Create a faulty user defined procudure and use to ERROR_PROCUDURE function
-- to get the name of the faulty procudure
if OBJECT_ID('usp_Example','P') is not null
	drop proc usp_Example;
Go
Create proc usp_Example
as
select 34/0;
--invoke the faulty procedure
begin try
	exec usp_Example;
end try
begin catch
	Select ERROR_PROCEDURE() as 'Faulty Procedure'
end catch;

-- Demonstrate how to throw and catch exceptions in TSQL
if OBJECT_ID('TestThrow','U') is not null
	drop table TestThrow; 
Create table TestThrow
(
	ID int primary key
); 
-- Try to insert duplicate records
begin try
	begin transaction
	insert into dbo.TestThrow
	values
	(1),
	(1);
	commit -- Won't be reached due to duplicate PKs
end try
begin catch
	Print 'Tried to insert duplicate records'
	rollback;
	throw; -- Re-throw the error
end catch