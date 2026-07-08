/*
===============================================================================
Script: init_database.sql
Purpose:
    Initialise the PostgreSQL data warehouse schemas.

Description:
    This script creates the bronze, silver, and gold schemas used in the
    medallion architecture.

Important:
    Run this script while connected to the data_warehouse database.
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;