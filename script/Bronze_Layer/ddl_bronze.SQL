/*
===============================================================================================================================
DDL Script: Create Bronze Table
===============================================================================================================================
Purpose:
       This script creates staging tables in the `bronze` schema of the `DataWareHouse` database.
       It first checks for and drops any existing versions of the tables to ensure a clean setup.
      These tables serve as raw data sources from CRM and ERP systems.
===============================================================================================================================
*/
use DataWareHouse
go

--Drop and recreate CRM customer information table
if OBJECT_ID('crm_cust_info','U') IS NOT NULL
drop table crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

--Drop and recreate CRM product information table
if OBJECT_ID('crm_prd_info','U') IS NOT NULL
drop table crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

--Drop and recreate CRM sales detail table
if OBJECT_ID('crm_sales_detail','U') IS NOT NULL
drop table crm_sales_detail;
CREATE TABLE bronze.crm_sales_detail(
sls_ord_num	nvarchar(50),
sls_prd_key	nvarchar(50),
sls_cust_id int,	
sls_order_dt int,	
sls_ship_dt	int,
sls_due_dt	int,
sls_sales int,	
sls_quantity int,	
sls_price int

);

--Drop and recreate ERP customer demographic table
if OBJECT_ID('erp_cst_az12','U') IS NOT NULL
drop table erp_cst_az12;
CREATE TABLE bronze.erp_cst_az12(
CID	nvarchar(50),
BDATE DATE,	
GEN NVARCHAR(50)

);

-- Drop and recreate ERP location table
if OBJECT_ID('erp_Loc_A101','U') IS NOT NULL
drop table erp_Loc_A101;
CREATE TABLE bronze.erp_Loc_A101(
CID	nvarchar(50),
CNTRY nvarchar(50)

);

--Drop and recreate ERP product categorization table
if OBJECT_ID('erp_px_g1v2','U') IS NOT NULL
drop table erp_px_g1v2;
CREATE TABLE bronze.erp_px_g1v2(
ID nvarchar(50),
CAT	nvarchar(50),
SUBCAT nvarchar(50),	
MAINTENANCE nvarchar(50)
);
