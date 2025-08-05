/*
============================================================================================================================
Stored Procedure: Load Bronze Layer(Source -> Bronze)
=============================================================================================================================
Purpose:
      This stored procedure loads raw data from external CSV files into the bronze layer of the DataWareHouse.  
    The action :
     --It truncates existing data in staging tables
     --Uses BULK INSERT to reload fresh data from CRM and ERP source systems.
Usage example:
    exec bronze.load_bronze
Prarameters:
    None
This stored Procedure does not accept the any parameters or return any values
===============================================================================================================================
*/
create or alter procedure bronze.load_bronze as
begin
  Declare @start_time datetime, @end_time datetime
	begin try
	 set @start_time = GETDATE();
		print '=======================================================================================================';
		print 'Loading Bronze Layer'
		print '=======================================================================================================';

		print '------------------------------------------------------------------------------------------------------';
		print 'Lading CRM Tables';
		print '------------------------------------------------------------------------------------------------------';

    --Load CRM Customer Info
	  set @start_time = GETDATE();
		print '>>Trancating Table: bronze.crm_cust_info';
		truncate table bronze.crm_cust_info
		print '>>Inserting Data Into: bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
		firstrow = 2,  --Skip header
		fieldterminator = ',',  --CSV column delimiter
		tablock   Lock table for performance
		);
		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';
    --select * from bronze.crm_cust_Info
    --select count(*) from bronze.crm_cust_Info
		--------------------------------------------------------------------------------------------------------------------------
    --Load CRM Product Info
    set @start_time = GETDATE();
		print '>>Trancating Table: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info

		print '>>Inserting Data Into: bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);

		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';

		--select * from bronze.crm_prd_info

		--select count(*) from bronze.crm_prd_info
		--------------------------------------------------------------------------------------------------------------------------
		--Load CRM Sales Detail
    set @start_time = GETDATE();
		print '>>Trancating Table: bronze.crm_sales_detail';
		truncate table bronze.crm_sales_detail

		print '>>Inserting Data Into: bronze.crm_sales_detail';
		bulk insert bronze.crm_sales_detail
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';

		--select * from bronze.crm_sales_detail
		--select count(*) from bronze.crm_sales_detail
	  -------------------------------------------------------------------------------------------------------------------------
		print '------------------------------------------------------------------------------------------------------';
		print 'Loading ERP Tables';
		print '------------------------------------------------------------------------------------------------------';
    --Load ERP Customer Data (AZ12)
    set @start_time = GETDATE();
		print '>>Trancating Table: bronze.erp_cst_az12';
		truncate table bronze.erp_cst_az12

		print '>>Inserting Data Into: bronze_erp_cst_az12';
		bulk insert bronze.erp_cst_az12
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';

		--select * from bronze.erp_cst_az12
    --select count(*) from bronze.erp_cst_az12
		---------------------------------------------------------------------------------------------------------------------------
		--Load ERP Location Data (A101)
    set @start_time = GETDATE();
		print '>>Trancating Table: bronze.erp_Loc_A101';
		truncate table bronze.erp_Loc_A101

		print '>>Inserting Data Into: bronze.erp_Loc_A101';
		bulk insert bronze.erp_Loc_A101
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';

		--select * from bronze.erp_Loc_A101

		--select count(*) from bronze.erp_Loc_A101
		-----------------------------------------------------------------------------------------------------------------------------
		--Load ERP Product Category Mapping (PX_CAT_G1V2)
    set @start_time = GETDATE();
		print '>>Truncating Table: bronze.erp_px_g1v2';
		truncate table bronze.erp_px_g1v2

		print '>>Inserting Data Into: bronze.erp_px_g1v2';
		bulk insert bronze.erp_px_g1v2
		from 'C:\Users\User\Downloads\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
		set @end_time = GETDATE();
		print '>>Load Duration: '+ cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';
    --select * from bronze.erp_px_g1v2
    --select count(*) from bronze.erp_px_g1v2
print '================================================================================================================================================';
print 'Loadind Bronze Layer is completed'
print '=Total Load Duration: ' + cast(Datediff(second, @start_time, @end_time) as nvarchar) + ' Seconds';
print '================================================================================================================================================';
end try

begin catch
	 print '============================================================================================================';
	 print 'ERROR OCCURED DURING LOADING BRONZE LAYER';
	 print 'Error Message: ' + Error_Message();
	 print 'Error Messages: ' + CAST(ERROR_NUMBER() as nvarchar);
	 print 'Error Meassage: ' + CAST(ERROR_STATE() as nvarchar);
	 print '=============================================================================================================';
end catch
end
