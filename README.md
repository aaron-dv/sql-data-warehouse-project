# Modern SQL Data Warehouse Project

## Overview

This project builds a modern SQL data warehouse using a medallion architecture.

The goal is to consolidate CRM and ERP sales data from CSV files, clean and standardise the data, and create a business-ready analytics model for reporting and analysis.

---

## Project Requirements

### Objective

Build a SQL data warehouse to consolidate sales data and support analytical reporting and informed decision-making.

### Specifications

- **Data Sources:** Import CRM and ERP data from CSV files.
- **Data Quality:** Clean and resolve data quality issues before analysis.
- **Integration:** Combine both source systems into a single analytics-ready model.
- **Scope:** Use the latest dataset only; historisation is not required.
- **Documentation:** Document the architecture, data flow, and final data model.

---

## Architecture

The warehouse follows a medallion architecture with three layers:

```text
Source CSV Files
        ↓
Bronze Layer
        ↓
Silver Layer
        ↓
Gold Layer
        ↓
Analytics / Reporting
```

| Layer | Purpose |
| --- | --- |
| Bronze | Raw source-aligned data |
| Silver | Cleaned and standardised data |
| Gold | Business-ready analytics model |

---

## Data Sources

| Source | Description |
| --- | --- |
| CRM | Customer, product, and sales transaction data |
| ERP | Customer demographic, location, and product category data |

---

## Expected Gold Model

The gold layer will use a dimensional model designed for analytical queries.

```text
gold.dim_customers
gold.dim_products
gold.fact_sales
```

---

## Repository Structure

```text
data-warehouse-project/
│
├── datasets/              # Source CSV files
│
├── docs/                  # Project documentation and diagrams
│   ├── data_architecture.drawio
│   ├── data_flow.drawio
│   ├── data_models.drawio
│   └── naming_conventions.md
│
├── scripts/               # SQL scripts
│   ├── bronze/            # Bronze layer DDL and load scripts
│   ├── silver/            # Silver layer DDL and transformation scripts
│   └── gold/              # Gold layer views / data model scripts
│
├── tests/                 # Data quality and validation checks
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Naming Conventions

| Object Type | Pattern | Example |
| --- | --- | --- |
| Schema | `<layer>` | `bronze`, `silver`, `gold` |
| Bronze table | `<sourcesystem>_<entity>` | `crm_cust_info` |
| Silver table | `<sourcesystem>_<entity>` | `crm_cust_info` |
| Gold dimension | `dim_<entity>` | `dim_customers` |
| Gold fact | `fact_<entity>` | `fact_sales` |
| Metadata column | `dwh_<column_name>` | `dwh_create_date` |
| Load procedure/script | `load_<layer>` | `load_bronze` |

---

## Tools

- SQL
- PostgreSQL
- DBeaver
- GitHub
- Draw.io
- Notion

---

## Skills Demonstrated

- Data warehouse design
- Medallion architecture
- SQL development
- Data ingestion from CSV files
- Data cleansing and standardisation
- Data integration
- Dimensional modelling
- Data quality checks
- Technical documentation
- Git-based project organisation

---

## Credits & References

This project is based on a guided SQL data warehouse project by Data with Baraa.

1. [SQL Data Warehouse from Scratch](https://www.youtube.com/watch?v=9GVqKuTVANE&t=7436s) - Data with Baraa
