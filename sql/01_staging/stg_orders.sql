-- =============================================================================
-- STAGING: stg_orders
-- Fonte: orders (tabela bruta carregada do CSV)
-- Descrição: Pedidos realizados na plataforma Olist.
--            Aqui fazemos apenas limpeza técnica — sem regras de negócio.
-- =============================================================================

CREATE OR REPLACE VIEW `olistdbt.staging.stg_orders` AS

SELECT
    -- Identificadores
    order_id,
    customer_id,

    -- Status do pedido (mantemos como string — sem transformação de negócio aqui)
    LOWER(TRIM(order_status)) AS order_status,

    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date

FROM `olistdbt.raw.orders`

-- Filtramos linhas onde o identificador principal é nulo.
-- Um pedido sem order_id é inválido e não pode ser usado em nenhuma camada.
WHERE order_id IS NOT NULL
