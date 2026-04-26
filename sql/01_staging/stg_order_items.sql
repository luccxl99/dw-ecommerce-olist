-- =============================================================================
-- STAGING: stg_order_items
-- Fonte: order_items (tabela bruta carregada do CSV)
-- Descrição: Itens individuais de cada pedido.
--            Um pedido pode ter múltiplos itens — a granularidade aqui é
--            1 linha = 1 item de 1 pedido.
-- =============================================================================

CREATE OR REPLACE VIEW `olistdbt.staging.stg_order_items` AS

SELECT
    -- Identificadores
    order_id,
    product_id,
    seller_id,

    -- Número sequencial do item dentro do pedido (1, 2, 3...)
    -- Usado para diferenciar itens do mesmo pedido
    CAST(order_item_id AS INT64) AS order_item_id,

    -- Data limite para envio pelo vendedor
    -- Convertemos de STRING para TIMESTAMP igual ao padrão do projeto
    shipping_limit_date,

    -- Valores financeiros: CSV bruta armazena como STRING.
    -- Convertemos para FLOAT64 para permitir somas, médias e cálculos na fato.
    CAST(price          AS FLOAT64) AS price,
    CAST(freight_value  AS FLOAT64) AS freight_value

FROM `olistdbt.raw.order_items`

-- Garantimos que apenas itens com pedido e produto identificáveis entram no pipeline
WHERE order_id   IS NOT NULL
  AND product_id IS NOT NULL
