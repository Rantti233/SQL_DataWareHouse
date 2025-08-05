/*
===============================================================================================================================
CREATE DATABASE AND SCHEMA
===============================================================================================================================
Script Purpose:
     This script create a new database name 'DataWareHouse' after checking if it already exist
     If it exists, script resets (drops and recreates) the DataWareHouse database 
     Creates standard schemas (bronze, silver, gold) for data staging.

WARNING:
    This script will permanently delete the existing 'DataWareHouse' database 
    (if it exists) and recreate it from scratch. All existing data will be lost.
     Proceed with caution
     Ensure: You have proper backup
*/
USE MASTER
GO

--Drop and Recreate the 'DataWareHouse' database
IF EXISTS(SELECT 1 FROM Sys.databases WHERE name = 'DataWareHouse')
BEGIN
 ALTER database DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
 DROP DATABASE DataWareHouse
END;
go --go seperate batches when working with multiple SQL

--Create the 'DataWareHouse' database
CREATE DATABASE DataWareHouse
Go
use datawarehouse
Go

--Create schema
--For raw or initial data ingestion
create schema bronze;
go 

--For cleaned, transformed intermediate data
create schema silver;
go

--For finalized, aggregated data ready for reporting
create schema gold;
go

--Revert database to MULTI_USER so others can access it
ALTER DATABASE DataWareHouse SET MULTI_USER;
GO
