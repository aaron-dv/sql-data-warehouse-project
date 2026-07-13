/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV
    files stored on the PostgreSQL server.

    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses PostgreSQL COPY to load CSV files into bronze tables.
    - Prints load progress and duration messages.

Important:
    COPY reads files from the PostgreSQL server filesystem.

    The CSV files must exist on the server and the PostgreSQL service
    user must have permission to read them.

Parameters:
    base_path - the absolute path of the dataset on the
    PostgreSQL server.

Usage Example:
    CALL bronze.load_bronze('/mnt/ehdd/dwh_project/datasets');
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze(
    base_path TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    start_time        TIMESTAMP;
    end_time          TIMESTAMP;
    batch_start_time  TIMESTAMP;
    batch_end_time    TIMESTAMP;

BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    EXECUTE format(
        'COPY bronze.crm_cust_info
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_crm/cust_info.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    EXECUTE format(
        'COPY bronze.crm_prd_info
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_crm/prd_info.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    EXECUTE format(
        'COPY bronze.crm_sales_details
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_crm/sales_details.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    EXECUTE format(
        'COPY bronze.erp_loc_a101
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_erp/LOC_A101.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    EXECUTE format(
        'COPY bronze.erp_cust_az12
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_erp/CUST_AZ12.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    start_time := clock_timestamp();

    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    EXECUTE format(
        'COPY bronze.erp_px_cat_g1v2
         FROM %L
         WITH (
             FORMAT csv,
             HEADER true,
             DELIMITER '',''
         )',
        base_path || '/source_erp/PX_CAT_G1V2.csv'
    );

    end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
    RAISE NOTICE '>> -------------';


    batch_end_time := clock_timestamp();

    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM batch_end_time - batch_start_time), 2);
    RAISE NOTICE '==========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
        RAISE NOTICE '==========================================';

        RAISE;
END;
$$;