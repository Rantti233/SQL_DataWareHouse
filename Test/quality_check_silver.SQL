/*
===================================================================================================================================
QUALITY CHECK
===================================================================================================================================
Purpose:
         --This script performs a series of data quality checks on the Silver layer tables
         --To identify null or duplicate records, unwanted space, invalid formats, missing or inconsistent data
         --Data conistency between related fields
Usage Notes:
          -- Rum these checks after data loading silver layer
          --Investigate and resolve any discripancies found during check
====================================================================================================================================
*/
-------------------------------------------
--Checking silver.crm_cust_info
-------------------------------------------
select cst_id,
COUNT(*)
from silver.crm_cust_info
group by cst_id
having COUNT(*) >1 or cst_id is null

select cst_lastname
from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

select distinct cst_gndr
from silver.crm_cust_info

-------------------------------------------
--Checking silver.crm_prd_info
-------------------------------------------
select prd_id,
COUNT(*)
from silver.crm_prd_info
group by prd_id
having COUNT(*) >1 or prd_id is null

select prd_nm
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm)


select distinct prd_line
from silver.crm_prd_info


select prd_cost
from silver.crm_prd_info
where prd_cost is null or prd_cost<0


select prd_id,prd_key,
prd_cost,prd_start_dt,prd_end_dt
from silver.crm_prd_info
where prd_end_dt<prd_start_dt

select *
from silver.crm_prd_info

-------------------------------------------
--Checking silver.crm_sales_detail
-------------------------------------------
select 
nullif(sls_order_dt,0)
from silver.crm_sales_detail
where sls_order_dt=0 or LEN(sls_order_dt) != 8


select *
from silver.crm_sales_detail
where sls_order_dt> sls_ship_dt or sls_ship_dt>sls_due_dt

select distinct sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_detail
where sls_sales != sls_quantity*sls_price
or sls_sales is null or  sls_quantity is null or sls_price is null
or sls_sales <= 0 or  sls_quantity <= 0 or sls_price <= 0

-------------------------------------------
--Checking silver.erp_cst_az12
-------------------------------------------
select cid, count(*)
from bronze.erp_cst_az12
group by cid
having count(*) > 1 or cid is null

select bdate
from silver.erp_cst_az12
where bdate < '1924-01-31' or bdate > GETDATE()

select distinct gen
from silver.erp_cst_az12
select * from silver.erp_cst_az12

-------------------------------------------
--Checking silver.erp_loc_a101
-------------------------------------------
select distinct cntry
from silver.erp_loc_a101
order by cntry

-------------------------------------------
--Checking silver.erp-px_g1v2
-------------------------------------------
select *
from silver.erp_px_g1v2
where cat != TRIM(cat)
or subcat != TRIM(subcat)
or maintanence != TRIM(maintanence)
