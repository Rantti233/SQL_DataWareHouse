/*
==================================================================================================================================
Stored Procedure: Load silver Layer (Bronze -> Silver
================================================================================================================================== 
Purpose:
    This procedure performs ETL(Extract, Transform and Load) data from the Bronze layer to the Silver layer.
    The Action:
            --Truncates silver Table
            --Insert Transform and cleansed data from Bronze layer to Silver Layer

*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
  BEGIN
    Declare @start_time datetime, @end_time datetime,@batch_start_time datetime, @batch_end_time datetime
    begin try
    set @batch_start_time = GETDATE()
    print '======================================================================================================='
    print 'Loading Silver Layer'
    print '======================================================================================================='

    print '------------------------------------------------------------------------------------------------------------'
    print 'Loading CRM Tables'
    print '------------------------------------------------------------------------------------------------------------'

    set @start_time = GETDATE();
    TRUNCATE TABLE silver.crm_cust_info
    insert into silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_FirstName,cst_LastName,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
    select cst_id,
    cst_key,
    TRIM(cst_firstname) as cst_FirstName,
    TRIM(cst_lastname) as cst_LastName,
    case
    when upper(trim(cst_marital_status))= 'M' then 'Married'
    when upper(trim(cst_marital_status)) = 'S' then 'Single'
    else 'n/a'
    end cst_marital_status,
    case
    when upper(trim(cst_gndr))= 'M' then 'Male'
    when upper(trim(cst_gndr)) = 'F' then 'Female'
    else 'n/a'
    end cst_gndr,
    cst_create_date
    from (
    select *,
    ROW_NUMBER() over(Partition by cst_id order by cst_create_date desc) as flag1
    from bronze.crm_cust_Info
    where cst_id is not null
    )t 
    where flag1 = 1
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------'

    ------------------------------------------------------------------------------------------------------
    set @start_time = GETDATE();
    TRUNCATE TABLE silver.crm_prd_info
    INSERT INTO silver.crm_prd_info(
          prd_id,
          cat_id,
          prd_key,
          prd_nm,
          prd_cost,
          prd_line,
          prd_start_dt,
          prd_end_dt
    )

    select 
    prd_id,
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
    SUBSTRING(prd_key,7,LEN(prd_key))as prd_key,
    prd_nm,
    ISNULL(prd_cost,0) as prd_cost,
    case UPPER(TRIM(prd_line)) 
         when 'M' then 'Mountain'
         when 'R' then 'Road'
         when 'S' then 'Other Sales'
         when 'T' then 'Touring'
    else 'n/a'
    end as prd_line,
    CAST(prd_start_dt as Date) as prd_start_dt,
    CAST(LEAD(prd_start_dt)over(partition by prd_key order by prd_start_dt)-1 AS DATE) as prd_end_dt
    from bronze.crm_prd_info
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------'
    ----------------------------------------------------------------------------------------------------
   set @start_time = GETDATE();
   TRUNCATE TABLE silver.crm_sales_detail
    INSERT INTO silver.crm_sales_detail(
           sls_ord_num,
           sls_prd_key,
           sls_cust_id,
           sls_order_dt,
           sls_ship_dt,
           sls_due_dt,
           sls_sales, 
           sls_quantity,
           sls_price
    )
    select
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 then NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END sls_order_dt,
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 then NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END sls_ship_dt,
    CASE WHEN sls_due_dt= 0 OR LEN(sls_due_dt) != 8 then NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END sls_due_dt,
    CASE WHEN sls_sales<=0 or sls_sales is null or sls_sales != sls_quantity *ABS(sls_price)
         then sls_quantity * ABS(sls_price)
    else sls_sales
    end sls_sales,
    sls_quantity,
    case 
        when sls_price is null or sls_price <= 0 then sls_sales/NULLIF(sls_quantity,0)
        else sls_price
    end sls_price
    from bronze.crm_sales_detail
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------'
    --------------------------------------------------------------------------------------------------
    print '------------------------------------------------------------------------------------------------------------'
    print 'Loading ERP Tables'
    print '------------------------------------------------------------------------------------------------------------'
    set @start_time = GETDATE();
    TRUNCATE TABLE silver.erp_cst_az12
    INSERT INTO silver.erp_cst_az12(
           cid,
           bdate,
           gen
    )
    select 
    case when cid like 'NAS%' then substring(cid, 4, len(cid))
    else cid
    end CID,
    case when BDATE > GETDATE() then NULL
         else BDATE
    end BDATE,
    case 
       when UPPER(TRIM(GEN)) IN('M', 'MALE') then 'Male'
       when UPPER(TRIM(GEN)) IN('F', 'FEMALE') then 'Female'
       else 'n/a'
    end GEN
    from bronze.erp_cst_az12
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------'
    ----------------------------------------------------------------------------------------------------
    set @start_time = GETDATE();
    TRUNCATE TABLE silver.erp_Loc_A101
    INSERT INTO silver.erp_Loc_A101(
           CID,
           CNTRY
    )
    select 
    REPLACE(CID, '-','') CID,
    CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
         WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
         else TRIM(CNTRY)
    END CNTRY
    from bronze.erp_Loc_A101
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------'
    ------------------------------------------------------------------------------------------------------
    set @start_time = GETDATE();
    TRUNCATE TABLE silver.erp_px_g1v2
    INSERT INTO silver.erp_px_g1v2(
           ID,
           CAT,
           SUBCAT,
           MAINTENANCE
    )
    select 
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
    from bronze.erp_px_g1v2
    set @end_time = GETDATE()
    print '>> Load Duration: ' + cast(dateDiff(second, @start_time, @end_time) as NVARCHAR) + 'Seconds'
    print '>>----------------------------------------------------';

    set @batch_end_time = GETDATE();
    print '===============================================================================================================';
    print 'Loading Silver Layer is Completed';
    print ' -Total Load Duration: ' + CAST(DATEDIFF(SECOND , @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
    print '================================================================================================================';

    end try
    begin catch
        print '============================================================================================================'
        print 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message' + Error_Message();
        PRINT 'Error Message' + CAST(Error_Number() AS NVARCHAR);
        PRINT 'Error Message' + CAST(Error_State() AS NVARCHAR);
        print '=============================================================================================================='

    end catch
END
