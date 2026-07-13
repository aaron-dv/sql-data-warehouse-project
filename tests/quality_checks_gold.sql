/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script performs data quality checks to validate the integrity,
    consistency, completeness, and analytical readiness of the Gold Layer.

    The checks cover:

    Dimension Views:
    - Uniqueness of surrogate keys.
    - Uniqueness of business identifiers.
    - Completeness of surrogate keys and business identifiers.

    Fact View:
    - Completeness of dimension keys and order identifiers.
    - Referential integrity between the fact and dimension views.
    - Detection of duplicate sales-order line records.
    - Validation of date completeness and chronological consistency.
    - Validation of sales measure completeness and permitted values.
    - Verification that sales amounts match the expected calculation.

Usage Notes:
    - Queries marked "Expectation: No results" should return zero rows.
    - Returned rows indicate records that require investigation.
    - Resolve identified issues before using the Gold Layer for reporting,
      analytics, or downstream consumption.
    - The duplicate fact-row check assumes that an order should contain no more
      than one row for the same customer and product combination.
    - The sales calculation check assumes the business rule:

          sales_amount = quantity * price

===============================================================================
*/

-- =============================================================================
-- Quality Checks: gold.dim_customers
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check customer surrogate-key uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check customer number uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    customer_number,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check customer ID uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check for missing customer surrogate keys
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- -----------------------------------------------------------------------------
-- Check for missing customer ids or numbers
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers
WHERE customer_id IS NULL
   OR customer_number IS NULL;


-- =============================================================================
-- Quality Checks: gold.dim_products
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check product surrogate-key uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check product ID uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check product number uniqueness
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    product_number,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check for missing product surrogate keys
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- -----------------------------------------------------------------------------
-- Check for missing product ids or numbers
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE product_id IS NULL
   OR product_number IS NULL;


-- =============================================================================
-- Quality Checks: gold.fact_sales
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Check for missing dimension keys
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;

-- -----------------------------------------------------------------------------
-- Check referential integrity between the fact and dimension views
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    f.*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;

-- -----------------------------------------------------------------------------
-- Check for missing order numbers
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE order_number IS NULL;

-- -----------------------------------------------------------------------------
-- Check for duplicate sales-order line records
-- Assumption:
--     An order should contain no more than one row for the same product.
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    order_number,
    product_key,
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.fact_sales
GROUP BY
    order_number,
    product_key,
    customer_key
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- Check date completeness and sequence
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE order_date IS NULL
   OR shipping_date IS NULL
   OR due_date IS NULL
   OR shipping_date < order_date
   OR due_date < order_date;

-- -----------------------------------------------------------------------------
-- Check for invalid sales measures
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.fact_sales
WHERE sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR sales_amount <= 0
   OR quantity <= 0
   OR price <= 0;

-- -----------------------------------------------------------------------------
-- Validate the sales amount calculation
-- Business Rule:
--     sales_amount = quantity * price
-- Expectation: No results
-- -----------------------------------------------------------------------------

SELECT
    order_number,
    product_key,
    customer_key,
    sales_amount,
    quantity,
    price,
    quantity * price AS expected_sales_amount
FROM gold.fact_sales
WHERE sales_amount <> quantity * price;

