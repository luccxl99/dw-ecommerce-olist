# E-Commerce Data Warehouse — Olist (BigQuery)

A end-to-end Data Warehouse project built on Google BigQuery using the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle. The goal is to transform raw transactional data into a clean, well-modeled analytical layer ready for business intelligence queries.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Architecture](#architecture)
- [Data Model](#data-model)
- [Project Structure](#project-structure)
- [Layer Details](#layer-details)
- [Quality Tests](#quality-tests)
- [How to Run](#how-to-run)
- [Sample Queries](#sample-queries)

---

## Project Overview

This project simulates a real-world data engineering workflow:

1. Raw CSV files are loaded into BigQuery as-is (the `raw` layer)
2. A **staging** layer cleans and standardizes the data technically
3. A **dimensional model** (star schema) is built on top of staging
4. **Quality tests** validate the pipeline at every critical point

**Tech stack:** Google BigQuery · SQL · Star Schema · Dimensional Modeling

---

## Dataset

The Olist dataset contains ~100k orders made at the Olist Store (a Brazilian e-commerce marketplace) between 2016 and 2018. It includes:

| File | Description |
|---|---|
| `olist_orders_dataset.csv` | Orders and their lifecycle timestamps |
| `olist_order_items_dataset.csv` | Individual items within each order |
| `olist_order_payments_dataset.csv` | Payment methods and values per order |
| `olist_customers_dataset.csv` | Customer information |
| `olist_sellers_dataset.csv` | Seller information |
| `olist_products_dataset.csv` | Product catalog |
| `olist_geolocation_dataset.csv` | GPS coordinates by ZIP code |
| `product_category_name_translation.csv` | Category names in English |

> **Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│   Raw CSVs  │────▶│   Staging   │────▶│     Dimensions      │────▶│    Facts         │
│  (as-is)    │     │  (cleaned)  │     │  (context tables)   │     │  (measurements)  │
└─────────────┘     └─────────────┘     └─────────────────────┘     └──────────────────┘
```

| Layer | Type | Purpose |
|---|---|---|
| `raw` | Tables | CSV files loaded as-is into BigQuery |
| `staging` | Views | Technical cleaning only — no business logic |
| `dimensions` | Tables | Descriptive context: who, what, where, when |
| `facts` | Table | Measurable events (orders) linked to dimensions |

---

## Data Model

> Full ERD with column-level detail: [docs/erd.md](docs/erd.md)

The project follows a **Star Schema** — the most common pattern in Data Warehousing.

```
                        ┌─────────────────┐
                        │   dim_date      │
                        │─────────────────│
                        │ date_sk (PK)    │
                        │ full_date       │
                        │ year / quarter  │
                        │ month / week    │
                        │ day_name        │
                        │ is_weekend      │
                        └────────┬────────┘
                                 │
┌─────────────────┐              │              ┌─────────────────┐
│  dim_customers  │              │              │   dim_sellers   │
│─────────────────│              │              │─────────────────│
│ customer_sk(PK) │              │              │ seller_sk (PK)  │
│ customer_       │              │              │ seller_id       │
│   unique_id     │              │              │ seller_city     │
│ customer_city   ├──────────────┤              │ seller_state    │
│ customer_state  │              │              │ latitude        │
│ latitude        │    ┌─────────┴────────┐     │ longitude       │
│ longitude       │    │   fct_orders     │─────┤─────────────────┘
└─────────────────┘    │──────────────────│
                       │ order_sk         │     ┌─────────────────┐
                       │ customer_sk (FK) │     │  dim_products   │
                       │ seller_sk   (FK) │     │─────────────────│
                       │ product_sk  (FK) │     │ product_sk (PK) │
                       │ payment_sk  (FK) │     │ product_id      │
                       │ date_sk     (FK) │─────│ category_en     │
                       │ ─────────────── │     │ weight / dims   │
                       │ item_price       │     └─────────────────┘
                       │ freight_value    │
                       │ total_payment    │     ┌─────────────────┐
                       │ days_to_deliver  │     │  dim_payments   │
                       │ days_early_late  │     │─────────────────│
                       └──────────────────┘     │ payment_sk (PK) │
                                                │ order_id        │
                                                │ payment_type    │
                                                │ total_value     │
                                                │ installments    │
                                                │ is_split        │
                                                └─────────────────┘
```

### Grain

The fact table has a grain of **1 row = 1 item within 1 order**. An order with 3 products generates 3 rows. This level of detail allows product-level analysis without losing order-level context.

---

## Project Structure

```
dw-ecommerce-olist/
│
├── data/
│   └── raw/                          # CSV files (not tracked in git)
│
├── sql/
│   ├── 01_staging/
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_order_payments.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_sellers.sql
│   │   ├── stg_products.sql
│   │   └── stg_geolocation.sql
│   │
│   ├── 02_dimensions/
│   │   ├── dim_customers.sql
│   │   ├── dim_sellers.sql
│   │   ├── dim_products.sql
│   │   ├── dim_date.sql
│   │   └── dim_payments.sql
│   │
│   ├── 03_facts/
│   │   └── fct_orders.sql
│   │
│   └── 04_quality_tests/
│       ├── test_not_null.sql
│       ├── test_unique_keys.sql
│       ├── test_referential_integrity.sql
│       └── test_business_rules.sql
│
└── README.md
```

---

## Layer Details

### Staging

Views that sit directly on top of raw tables. Rules applied here:

- Cast strings to proper types (`FLOAT64`, `INT64`, `TIMESTAMP`)
- Standardize text: `TRIM()`, `UPPER()`, `INITCAP()`
- Filter rows with null primary keys
- No business logic — that belongs in the dimensional layer

**Notable decisions:**
- `stg_geolocation`: deduplicated by ZIP code using `AVG(lat/lng)` — the raw file has multiple coordinates per ZIP
- `stg_products`: joined with the category translation table to expose English category names
- `stg_customers`: preserves both `customer_id` (per-order) and `customer_unique_id` (real unique customer) — a known quirk of the Olist dataset

### Dimensions

Materialized tables that describe the "who", "what", "where", and "when" of each order.

| Table | Key | Description |
|---|---|---|
| `dim_customers` | `customer_unique_id` | One row per real customer, deduplicated, enriched with geo coordinates |
| `dim_sellers` | `seller_id` | Sellers enriched with geo coordinates |
| `dim_products` | `product_id` | Product catalog with physical dimensions and English category |
| `dim_date` | `YYYYMMDD` integer | Full calendar from 2016 to 2018, with year/quarter/month/week/day attributes |
| `dim_payments` | `order_id` | Payment consolidated per order — primary method, total value, installments |

All dimensions use a **surrogate key** generated via `FARM_FINGERPRINT()` — a native BigQuery deterministic hash. This decouples the warehouse from source system IDs.

### Facts

`fct_orders` is the central fact table. It stores one row per order item and contains:

- Foreign keys to all 5 dimensions
- Financial metrics: `item_price`, `item_freight_value`, `total_payment_value`
- Derived time metrics: `days_to_deliver`, `days_early_or_late`

---

## Quality Tests

Each test file returns a result set. **A test passes when it returns 0 rows.**

| File | What it checks |
|---|---|
| `test_not_null.sql` | Critical columns (PKs, FKs) must never be null |
| `test_unique_keys.sql` | Primary keys must be unique across all dimension tables |
| `test_referential_integrity.sql` | Every FK in the fact table must point to an existing dimension row |
| `test_business_rules.sql` | Domain rules: no negative prices, delivery date after purchase date, etc. |

---

## How to Run

### Prerequisites

- A Google Cloud project with BigQuery enabled (the free [BigQuery Sandbox](https://cloud.google.com/bigquery/docs/sandbox) works — no credit card required)
- The Olist CSV files downloaded from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Steps

1. **Create the BigQuery datasets**

   In the BigQuery console, create four datasets under your project: `raw`, `staging`, `dimensions`, `facts`.

2. **Load raw CSVs into BigQuery**

   For each CSV, create a table in the `raw` dataset using the BigQuery console (Upload → Auto-detect schema). Use the following table names:

   | CSV file | Table name |
   |---|---|
   | `olist_orders_dataset.csv` | `orders` |
   | `olist_order_items_dataset.csv` | `order_items` |
   | `olist_order_payments_dataset.csv` | `order_payments` |
   | `olist_customers_dataset.csv` | `customers` |
   | `olist_sellers_dataset.csv` | `sellers` |
   | `olist_products_dataset.csv` | `products` |
   | `olist_geolocation_dataset.csv` | `geolocation` |
   | `product_category_name_translation.csv` | `product_category_translation` |

3. **Replace the project ID**

   All SQL files reference `olistdbt` as the GCP project ID. Replace it with your own project ID before running:

   ```bash
   find ./sql -name "*.sql" -exec sed -i 's/olistdbt/YOUR-PROJECT-ID/g' {} +
   ```

4. **Run in order**

   Open each file in the BigQuery console editor and click **Run**:

   ```
   01_staging/       → run all stg_*.sql files
   02_dimensions/    → run all dim_*.sql files
   03_facts/         → run fct_orders.sql
   04_quality_tests/ → run all test_*.sql files and verify 0 rows returned
   ```

### Implementation notes

- **Timestamp columns:** BigQuery auto-detect identifies date columns in the Olist CSVs as `TIMESTAMP` directly, so no `PARSE_TIMESTAMP` conversion is needed in staging.
- **Geolocation deduplication:** The raw geolocation dataset has multiple coordinates per ZIP code. `stg_geolocation` averages them by ZIP. The JOIN in `dim_customers` and `dim_sellers` further aggregates to one row per ZIP to prevent row multiplication.
- **Category translation:** If the `product_category_translation` table throws a column-not-found error, re-upload the CSV with an explicit schema (`product_category_name:STRING,product_category_name_english:STRING`) instead of auto-detect — the CSV may contain a BOM character in the header.

---

## Sample Queries

Once the model is built, you can answer business questions with simple queries:

**Revenue by product category (top 10)**
```sql
SELECT
    p.product_category_name_en,
    ROUND(SUM(f.item_price), 2)  AS total_revenue,
    COUNT(DISTINCT f.order_id)   AS total_orders
FROM `your_project.facts.fct_orders` f
JOIN `your_project.dimensions.dim_products` p USING (product_sk)
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10
```

**Average delivery time by state**
```sql
SELECT
    c.customer_state,
    ROUND(AVG(f.days_to_deliver), 1) AS avg_days_to_deliver
FROM `your_project.facts.fct_orders` f
JOIN `your_project.dimensions.dim_customers` c USING (customer_sk)
WHERE f.days_to_deliver IS NOT NULL
GROUP BY 1
ORDER BY avg_days_to_deliver DESC
```

**Monthly revenue trend**
```sql
SELECT
    d.year_month,
    ROUND(SUM(f.item_price), 2) AS monthly_revenue
FROM `your_project.facts.fct_orders` f
JOIN `your_project.dimensions.dim_date` d USING (date_sk)
GROUP BY 1
ORDER BY 1
```

---

## Author

Lucca Moreno

Built as a portfolio project to demonstrate data engineering skills with Google Cloud and BigQuery.
