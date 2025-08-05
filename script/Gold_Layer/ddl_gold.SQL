/*
=================================================================================================================================
DDL Script: Create Gold Views
=================================================================================================================================
Purpose:
          --This script creates the Gold layer views for customer, product, and sales data.
          --These views serve as dimension and fact tables(Star Schema) for analytical/reporting purposes.
          --It includes logic to clean, standardize, and business ready datasets from the Silver layer.

Usage:
     --This views can be quried directly for analytics and reporting
=================================================================================================================================
*/
if OBJECT_ID('gold.dim_customers','V') IS NOT NULL
drop view gold.dim_customers;
go
--Create customer dimension view
CREATE VIEW gold.dim_customers AS
select
    ROW_NUMBER() OVER(ORDER BY cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	A101.CNTRY as country,
	ci.cst_marital_status as marital_status,
  --Prefer CRM gender; fallback to ERP gender
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the master for gender index
	else coalesce(az.GEN, 'n/a')
	end as gender,
	az.BDATE as birth_date,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
left join silver.erp_cst_az12 as az on az.CID = ci.cst_key
left join silver.erp_Loc_A101 as A101 on A101.CID = ci.cst_key
go
-------------------------------------------------------------------------------------------------
if OBJECT_ID('gold.dim_products','V') IS NOT NULL
drop view gold.dim_products;
go
--Create product dimension view
CREATE VIEW gold.dim_products as
select
    ROW_NUMBER() OVER(ORDER BY prd.prd_start_dt,prd.prd_key) as product_key,
	prd.prd_id as product_id,
	prd.prd_key as product_number,
	prd.prd_nm as product_name,
	prd.cat_id as category_id,
	g1v2.CAT as category,
	g1v2.SUBCAT as subcategory,
	g1v2.MAINTENANCE as maintenance,
	prd.prd_cost as cost,
	prd.prd_line as product_line,
	prd.prd_start_dt as start_date
from silver.crm_prd_info prd
left join silver.erp_px_g1v2 g1v2 on  prd.cat_id = g1v2.ID
where prd.prd_end_dt is null --Filtetr out all historical data
go
--------------------------------------------------------------------------------------------------
if OBJECT_ID('gold.fact_sales','V') IS NOT NULL
drop view gold.fact_sales;
go
--Create sales fact view
CREATE VIEW gold.fact_sales as
select
sls.sls_ord_num as order_number,
pr.product_key,
cs.customer_key,
sls.sls_order_dt as order_date,
sls.sls_ship_dt as shipping_date,
sls.sls_due_dt as due_date,
sls.sls_sales as sales_amount,
sls.sls_quantity as quantity,
sls.sls_price as price
from silver.crm_sales_detail sls
left join gold.dim_products pr on sls.sls_prd_key = pr.product_number
left join gold.dim_customers cs on sls.sls_cust_id = cs.customer_id
go
