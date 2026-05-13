/* Session 05 covers creating and managing database in SQL Server. */

-- Create the Customer database
<<<<<<< HEAD
create database [Customer_DB_ADSE2509]
on Primary -- File group where the customer database will be created
( Name = 'Customer_DB_ADSE2509',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL_SVR2025\MSSQL\DATA\Customer_DB_ADSE2509.mdf') -- Location of the master datafile
Log on
( Name = 'Customer_DB_ADSE2509_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL_SVR2025\MSSQL\DATA\Customer_DB_ADSE2509_Log.ldf') -- Location of the database log file
Collate SQL_latin1_General_CP1_CI_AS;

-- Change the name of the Customer_DB to Cust_DB
alter database customer_db_adse2509
modify name = [Cust_db_adse2509];

-- Switch to the Customer database
use Cust_db_adse2509;

-- Drop (Permanently Delete!) NB: take a full back-up to prevent accidental data loss
drop database Cust_db_adse2509;  -- Drop operation cannot be undone!
=======
create database [Machuki_adse_2509_custdb]
on Primary -- File group where the customer database will be created
( Name = 'Machuki_adse_2509_custdb',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL_SVR2025\MSSQL\DATA\Machuki_adse_2509_custdb.mdf') -- Location of the master datafile
Log on
( Name = 'Customer_DB_ADSE2509_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQL_SVR2025\MSSQL\DATA\Machuki_adse_2509_custdb_Log.ldf') -- Location of the database log file
Collate SQL_latin1_General_CP1_CI_AS;

-- Change the name of the Customer_DB to Cust_DB
alter database Machuki_adse_2509_custdb
modify name = [Machuki_adse_2509_custdb];

-- Switch to the Customer database
use Machuki_adse_2509_custdb;

-- Drop (Permanently Delete!) NB: take a full back-up to prevent accidental data loss
drop database Machuki_adse_2509_custdb;  -- Drop operation cannot be undone!
>>>>>>> 772cbe4 (Initial commit)
