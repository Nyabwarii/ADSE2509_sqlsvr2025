/*Session 1 4covers transactions in sql server*/

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

--create a custom 
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

--the existing  upSaveTransExample 
drop proc uspSaveTransExample;

CREATE PROC uspSaveTransExample
@inputCandidateID INT
AS
BEGIN
    DECLARE @transCounter INT;
    SET @transCounter = @@TRANCOUNT;
 
    IF @transCounter > 0
    BEGIN
        SAVE TRAN ProcedureSave;
    END
    ELSE
    BEGIN
        BEGIN TRAN;
    END
 
    BEGIN TRY
        DELETE FROM AdventureWorks2022.HumanResources.JobCandidate
        WHERE JobCandidateID = @inputCandidateID;
 
        IF @transCounter = 0
        BEGIN
            COMMIT TRAN;
            PRINT 'Transaction committed successfully.';
        END
        ELSE
        BEGIN
            PRINT 'Savepoint created and DELETE successful inside existing transaction.';
        END
    END TRY
    BEGIN CATCH
        IF @transCounter = 0
        BEGIN
            ROLLBACK TRAN;
            PRINT 'Transaction rolled back due to error.';
        END
        ELSE
        BEGIN
            ROLLBACK TRAN ProcedureSave;
            PRINT 'Rolled back to savepoint due to error.';
        END        
    END CATCH
END;

--Execute the above stored procedure to remove employee number 13
exec upSaveTransExample;

Demonstrate the use of @@trancount function in nested begin and commit statements


