# Naming Conventions

This document outlines the naming conventions used for schemas, tables, views, columns, stored procedures, load scripts, and other objects in the data warehouse.

## Table of Contents

1. [General Naming Rules](#general-naming-rules)
2. [Table and View Naming Conventions](#table-and-view-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Key Naming](#surrogate-key-naming)
   - [Technical Metadata Column Naming](#technical-metadata-column-naming)
4. [Stored Procedure and Load Script Naming](#stored-procedure-and-load-script-naming)
5. [Final Naming Convention Decisions](#final-naming-convention-decisions)
6. [Project Decision Summary](#project-decision-summary)

---

## General Naming Rules

- Use `snake_case`.
- Use lowercase names.
- Use English names.
- Avoid spaces.
- Avoid special characters.
- Avoid SQL reserved words.
- Use clear and descriptive names.

---

## Table and View Naming Conventions

### Bronze Rules

Bronze table names must start with the source system name, and table names must match their original source names without unnecessary renaming.

**Pattern**

```text
<sourcesystem>_<entity>
```

**Meaning**

- `<sourcesystem>`: Name of the source system, such as `crm` or `erp`.
- `<entity>`: Original table, file, or entity name from the source system.

**Example**

```text
CRM source file `cust_info.csv` → bronze.crm_cust_info
```

### Silver Rules

Silver table names follow the same naming convention as Bronze.

**Pattern**

```text
<sourcesystem>_<entity>
```

**Meaning**

- `<sourcesystem>`: Name of the source system, such as `crm` or `erp`.
- `<entity>`: Original table, file, or entity name from the source system.

**Example**

```text
bronze.crm_cust_info → silver.crm_cust_info
```

### Gold Rules

Gold object names must use meaningful, business-aligned names and start with a category prefix.

**Pattern**

```text
<category>_<entity>
```

**Meaning**

- `<category>`: Analytical object type, such as `dim`, `fact`, or `agg`.
- `<entity>`: Business entity or analytical subject.

**Examples**

```text
dim_customers
dim_products
fact_sales
agg_sales_monthly
```

**Reason**

Gold is business-facing and may combine data from multiple source systems. Gold objects should therefore be named according to business meaning rather than source system.

### Gold Category Prefixes

| Prefix | Meaning | Example |
|---|---|---|
| `dim_` | Dimension object | `dim_customers` |
| `fact_` | Fact object | `fact_sales` |
| `agg_` | Aggregated analytical object | `agg_sales_monthly` |

---

## Column Naming Conventions

Column names must use `snake_case`.

**Examples**

```text
customer_id
customer_key
first_name
last_name
order_date
sales_amount
product_key
```

Column names should be clear, descriptive, and consistent.

### Surrogate Key Naming

Surrogate keys in the Gold Layer must use the entity name followed by `_key`.

**Pattern**

```text
<entity>_key
```

**Examples**

```text
customer_key
product_key
```

**Reason**

This clearly identifies the key as belonging to a specific business entity.

### Technical Metadata Column Naming

Technical metadata columns created by the data warehouse process must use the `dwh_` prefix.

**Pattern**

```text
dwh_<column_name>
```

**Examples**

```text
dwh_create_date
dwh_load_date
dwh_update_date
```

**Reason**

The `dwh_` prefix makes it clear that the column was added by the data warehouse process and did not come directly from a source system.

For this project, the main metadata column is:

```text
dwh_create_date
```

---

## Stored Procedure and Load Script Naming

Stored procedures and load scripts used for loading data must use the `load_` prefix.

**Pattern**

```text
load_<layer>
```

**Examples**

```text
load_bronze
load_silver
```

**Reason**

The procedure or script name should clearly identify the warehouse layer it loads.

---

## Final Naming Convention Decisions

| Object Type | Pattern | Example |
|---|---|---|
| Schema | `<layer>` | `bronze`, `silver`, `gold` |
| Bronze table | `<sourcesystem>_<entity>` | `crm_cust_info` |
| Silver table | `<sourcesystem>_<entity>` | `crm_cust_info` |
| Gold dimension | `dim_<entity>` | `dim_customers` |
| Gold fact | `fact_<entity>` | `fact_sales` |
| Gold aggregate | `agg_<entity>_<grain>` | `agg_sales_monthly` |
| Surrogate key | `<entity>_key` | `customer_key` |
| Metadata column | `dwh_<column_name>` | `dwh_create_date` |
| Load procedure or script | `load_<layer>` | `load_bronze` |

---

## Project Decision Summary

This project uses:

- `snake_case` naming
- lowercase object names
- English names
- `bronze`, `silver`, and `gold` schemas
- `<sourcesystem>_<entity>` for Bronze and Silver tables
- `<category>_<entity>` for Gold objects
- the `dwh_` prefix for technical metadata columns
- the `load_` prefix for load procedures and scripts

Bronze and Silver names remain close to the source systems to support lineage.

Gold names are business-friendly because the Gold Layer is designed for analytics and reporting.