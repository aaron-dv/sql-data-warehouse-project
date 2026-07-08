/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    This script creates three schemas within the 'data_warehouse' database:
    'bronze', 'silver', and 'gold'.

    These schemas represent the medallion architecture layers used in this
    data warehouse project.
*/

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;