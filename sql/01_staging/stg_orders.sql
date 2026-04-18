-- =============================================================================
-- STAGING: stg_orders
-- Fonte: olist_orders_dataset (tabela bruta carregada do CSV)
-- Descrição: Pedidos realizados na plataforma Olist.
--            Aqui fazemos apenas limpeza técnica — sem regras de negócio.
-- =============================================================================

CREATE OR REPLACE VIEW `your_project.staging.stg_orders` AS

SELECT
    -- Identificadores
    order_id,
    customer_id,

    -- Status do pedido (mantemos como string — sem transformação de negócio aqui)
    LOWER(TRIM(order_status)) AS order_status,

    -- Timestamps: o BigQuery armazena como STRING no CSV bruto.
    -- Convertemos para TIMESTAMP para permitir cálculos de tempo depois.
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', order_purchase_timestamp)        AS order_purchase_timestamp,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', order_approved_at)               AS order_approved_at,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', order_delivered_carrier_date)    AS order_delivered_carrier_date,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', order_delivered_customer_date)   AS order_delivered_customer_date,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', order_estimated_delivery_date)   AS order_estimated_delivery_date

FROM `your_project.raw.olist_orders_dataset`

-- Filtramos linhas onde o identificador principal é nulo.
-- Um pedido sem order_id é inválido e não pode ser usado em nenhuma camada.
WHERE order_id IS NOT NULL
