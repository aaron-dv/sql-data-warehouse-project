/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardisation across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after loading the Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================


-- Check for NULL or duplicate values in primary key
-- Expectation: No results

SELECT 
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT 
	*
FROM
	(
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM silver.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
WHERE t.flag_last != 1;

-- Check for trailing or leading whitespaces
-- Expectation: No results

SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT
	cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT
	cst_marital_status  
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT
	cst_gndr   
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Data Standardisation & Consistency
-- Review the returned values and confirm they match the expected domain:

-- 'Single', 'Married', and 'n/a'
SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info;

-- 'Female', 'Male', and 'n/a'
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================


-- Check for NULL or duplicate values in primary key
-- Expectation: No results

SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for trailing or leading whitespaces
-- Expectation: No results

SELECT 
	prd_key
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

SELECT
	prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT
	prd_line  
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line);

-- Check for NULL or negative values
-- Expectation: No results

SELECT
	prd_cost  
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardisation & Consistency

SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Dates
-- Expectation: No results

SELECT *
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;

-- Full table overview

SELECT *
FROM silver.crm_prd_info; 


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================


-- Check for records with invalid foreign keys
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Check for trailing or leading whitespaces
-- Expectation: No results

SELECT 
	sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT
	sls_prd_key 
FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key);

-- Check for Invalid Dates
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_order_dt > DATE '2040-01-01'
   OR sls_order_dt < DATE '1900-01-01';

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR sls_ship_dt > DATE '2040-01-01'
   OR sls_ship_dt < DATE '1900-01-01';

SELECT *
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL
   OR sls_due_dt > DATE '2040-01-01'
   OR sls_due_dt < DATE '1900-01-01';

-- Check for Invalid Order Dates
-- Expectation: No results

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check data consistency: Sales, Quantity, and Price relationships
-- >> Sales = Quantity * Price
-- >> Values cannot be NULL, 0, or negative
-- Expectation: No results

SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY 
	sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================


-- Check for records with invalid foreign keys
-- Expectation: No results

SELECT COUNT(*)
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Check for trailing or leading whitespaces
-- Expectation: No results

SELECT 
	cid
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid);

SELECT
	gen 
FROM silver.erp_cust_az12
WHERE gen != TRIM(gen);

-- Check for Invalid Dates
-- Expectation: No results

SELECT *
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE
   OR bdate < DATE '1924-01-01';

-- Data Standardisation & Consistency
-- Review the returned values and confirm they match the expected domain:

-- 'Female', 'Male', and 'n/a'
SELECT DISTINCT gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================


-- Check for records with invalid foreign keys
-- Expectation: No results

SELECT COUNT(*)
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Check for trailing or leading whitespaces
-- Expectation: No results

SELECT 
	cid
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid);

SELECT
	cntry 
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry);

-- Data Standardisation & Consistency

SELECT DISTINCT cntry 
FROM silver.erp_loc_a101;


-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================


-- Check Table Overview
-- Review the returned rows for obvious anomalies

SELECT *
FROM silver.erp_px_cat_g1v2;

-- Check for Unwanted Spaces
-- Expectation: No results

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardisation & Consistency

SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
































































































































