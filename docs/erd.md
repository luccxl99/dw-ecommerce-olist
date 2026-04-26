# Entity-Relationship Diagram

Star schema of the Olist Data Warehouse. The fact table sits at the center, connected to five dimension tables.

```mermaid
erDiagram
    fct_orders {
        INT64   customer_sk     FK
        INT64   seller_sk       FK
        INT64   product_sk      FK
        INT64   payment_sk      FK
        INT64   date_sk         FK
        STRING  order_id
        STRING  order_status
        INT64   order_item_id
        FLOAT64 item_price
        FLOAT64 item_freight_value
        FLOAT64 item_total_value
        FLOAT64 total_payment_value
        INT64   days_to_deliver
        INT64   days_early_or_late
    }

    dim_customers {
        INT64   customer_sk         PK
        STRING  customer_unique_id
        STRING  customer_city
        STRING  customer_state
        FLOAT64 customer_latitude
        FLOAT64 customer_longitude
    }

    dim_sellers {
        INT64   seller_sk       PK
        STRING  seller_id
        STRING  seller_city
        STRING  seller_state
        FLOAT64 seller_latitude
        FLOAT64 seller_longitude
    }

    dim_products {
        INT64   product_sk                  PK
        STRING  product_id
        STRING  product_category_name_pt
        STRING  product_category_name_en
        INT64   product_name_length
        INT64   product_description_length
        INT64   product_photos_qty
        FLOAT64 product_weight_g
        FLOAT64 product_length_cm
        FLOAT64 product_height_cm
        FLOAT64 product_width_cm
    }

    dim_date {
        INT64   date_sk         PK
        DATE    full_date
        INT64   year
        INT64   quarter
        INT64   month
        STRING  month_name
        INT64   week_of_year
        INT64   day_of_month
        STRING  day_name
        BOOL    is_weekend
        STRING  year_quarter
        STRING  year_month
    }

    dim_payments {
        INT64   payment_sk              PK
        STRING  order_id
        STRING  primary_payment_type
        FLOAT64 total_payment_value
        INT64   max_installments
        INT64   payment_methods_count
        BOOL    is_split_payment
    }

    dim_customers  ||--o{ fct_orders : "customer_sk"
    dim_sellers    ||--o{ fct_orders : "seller_sk"
    dim_products   ||--o{ fct_orders : "product_sk"
    dim_date       ||--o{ fct_orders : "date_sk"
    dim_payments   ||--o{ fct_orders : "payment_sk"
```

## Grain

`fct_orders` has a grain of **1 row = 1 item within 1 order**. An order with 3 products generates 3 rows, enabling product-level analysis without losing order-level context.

## Surrogate Keys

All surrogate keys (`_sk`) are generated via `FARM_FINGERPRINT()` — a native BigQuery deterministic hash. This decouples the warehouse from source system IDs and ensures consistent key generation across full refreshes.
