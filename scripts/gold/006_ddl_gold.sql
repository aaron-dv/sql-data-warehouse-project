/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold Layer of the data warehouse.

    The Gold Layer represents the final dimensional model, consisting of
    customer and product dimensions and a sales fact view.

    Each view combines and transforms data from the Silver Layer to produce
    clean, enriched, and business-ready datasets.

Usage:
    These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Drop existing Gold views in reverse dependency order
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales;
DROP VIEW IF EXISTS gold.dim_products;
DROP VIEW IF EXISTS gold.dim_customers;


-- =============================================================================
-- Create Dimension View: gold.dim_customers
-- =============================================================================


CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	cci.cst_id AS customer_id,
	cci.cst_key AS customer_number,
	cci.cst_firstname AS first_name,
	cci.cst_lastname AS last_name,
	ela.cntry AS country,
	cci.cst_marital_status AS marital_status,
	COALESCE(
        NULLIF(TRIM(cci.cst_gndr), ''),
        NULLIF(TRIM(eca.gen), ''),
        'n/a'
    ) AS gender,
	eca.bdate AS birthdate,
	cci.cst_create_date AS create_date
FROM
	silver.crm_cust_info cci
LEFT JOIN 
	silver.erp_cust_az12 eca
ON
	cci.cst_key = eca.cid
LEFT JOIN 
	silver.erp_loc_a101 ela
ON
	cci.cst_key = ela.cid;


-- =============================================================================
-- Create Dimension View: gold.dim_products
-- =============================================================================


CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
	cpi.prd_id AS product_id,
	cpi.prd_key AS product_number,
	cpi.prd_nm AS product_name,
	cpi.cat_id AS category_id,
	epcg.cat AS category,
	epcg.subcat AS subcategory,
	epcg.maintenance,
	cpi.prd_cost AS cost,
	cpi.prd_line AS product_line,
	cpi.prd_start_dt AS start_date
FROM
	silver.crm_prd_info cpi
LEFT JOIN 
	silver.erp_px_cat_g1v2 epcg
ON 
	cpi.cat_id = epcg.id
WHERE cpi.prd_end_dt IS NULL; -- Filter out all historic data


-- =============================================================================
-- Create Fact View: gold.fact_sales
-- =============================================================================


CREATE VIEW gold.fact_sales AS
SELECT
    sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sls_order_dt AS order_date,
    sls_ship_dt AS shipping_date,
    sls_due_dt AS due_date,
    sls_sales AS sales_amount,
    sls_quantity AS quantity,
    sls_price AS price
FROM
    silver.crm_sales_details csd
LEFT JOIN 
	gold.dim_products dp
ON 
	csd.sls_prd_key = dp.product_number
LEFT JOIN 
	gold.dim_customers dc
ON 
	csd.sls_cust_id = dc.customer_id;
