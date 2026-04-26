-- =============================================================================
-- FATO: fct_orders
-- Fonte: stg_orders + stg_order_items + dim_customers + dim_sellers
--        + dim_products + dim_payments + dim_date
-- Descrição: Tabela fato central do DW. Granularidade: 1 linha = 1 item
--            de 1 pedido. Ou seja, um pedido com 3 produtos gera 3 linhas.
--            Essa granularidade permite análises por produto sem perder
--            informações do pedido.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.facts.fct_orders` AS

SELECT
    -- -------------------------------------------------------------------------
    -- Chaves surrogate (FKs para as dimensões)
    -- -------------------------------------------------------------------------
    FARM_FINGERPRINT(o.order_id)                           AS order_sk,
    FARM_FINGERPRINT(c.customer_unique_id)                 AS customer_sk,
    FARM_FINGERPRINT(i.seller_id)                          AS seller_sk,
    FARM_FINGERPRINT(i.product_id)                         AS product_sk,
    FARM_FINGERPRINT(o.order_id)                           AS payment_sk,
    CAST(FORMAT_DATE('%Y%m%d',
        DATE(o.order_purchase_timestamp))  AS INT64)       AS date_sk,

    -- -------------------------------------------------------------------------
    -- Chaves naturais (úteis para debugging e rastreabilidade)
    -- -------------------------------------------------------------------------
    o.order_id,
    o.customer_id,
    i.seller_id,
    i.product_id,

    -- -------------------------------------------------------------------------
    -- Atributos do pedido
    -- -------------------------------------------------------------------------
    o.order_status,
    i.order_item_id,

    -- Timestamps relevantes do ciclo de vida do pedido
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- -------------------------------------------------------------------------
    -- Métricas (os "fatos" em si — valores numéricos agregáveis)
    -- -------------------------------------------------------------------------

    -- Valores do item
    i.price               AS item_price,
    i.freight_value       AS item_freight_value,
    i.price + i.freight_value AS item_total_value,

    -- Valor total do pedido (vem da dimensão de pagamentos)
    p.total_payment_value,

    -- Métricas de tempo (dias) — calculadas aqui para facilitar análises
    DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_purchase_timestamp),
        DAY
    ) AS days_to_deliver,

    DATE_DIFF(
        DATE(o.order_estimated_delivery_date),
        DATE(o.order_delivered_customer_date),
        DAY
    ) AS days_early_or_late  -- positivo = adiantado, negativo = atrasado

FROM `olistdbt.staging.stg_orders` o

-- Cada pedido tem 1 ou mais itens — o JOIN expande para a granularidade item
INNER JOIN `olistdbt.staging.stg_order_items` i
    ON o.order_id = i.order_id

-- Buscamos o customer_unique_id para poder fazer o JOIN com dim_customers
INNER JOIN `olistdbt.staging.stg_customers` c
    ON o.customer_id = c.customer_id

-- Pagamentos: LEFT JOIN pois alguns pedidos podem não ter pagamento registrado
LEFT JOIN `olistdbt.dimensions.dim_payments` p
    ON o.order_id = p.order_id

-- Excluímos pedidos sem data de compra — não é possível calcular métricas de tempo
WHERE o.order_purchase_timestamp IS NOT NULL
