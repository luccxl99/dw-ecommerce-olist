-- =============================================================================
-- DIMENSÃO: dim_payments
-- Fonte: stg_order_payments
-- Descrição: Dimensão dos tipos e condições de pagamento.
--            Aqui consolidamos os pagamentos por pedido — somando o valor total
--            e identificando o tipo de pagamento principal.
--            Isso evita que a tabela fato precise lidar com múltiplas linhas
--            de pagamento por pedido.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.dimensions.dim_payments` AS

WITH payment_summary AS (
    SELECT
        order_id,

        -- Valor total pago no pedido (pode ter múltiplos métodos)
        SUM(payment_value) AS total_payment_value,

        -- Total de parcelas do método principal (maior valor)
        MAX(payment_installments) AS max_installments,

        -- Contagem de métodos de pagamento distintos usados
        COUNT(DISTINCT payment_type) AS payment_methods_count,

        -- Flag: pedido usou mais de um método de pagamento
        CASE WHEN COUNT(DISTINCT payment_type) > 1 THEN TRUE ELSE FALSE END AS is_split_payment

    FROM `olistdbt.staging.stg_order_payments`
    GROUP BY order_id
),

primary_payment AS (
    -- Identifica o tipo de pagamento com maior valor no pedido
    SELECT
        order_id,
        payment_type AS primary_payment_type,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC
        ) AS rn
    FROM `olistdbt.staging.stg_order_payments`
)

SELECT
    -- Chave surrogate
    FARM_FINGERPRINT(s.order_id) AS payment_sk,

    -- Chave natural (FK para a tabela fato via order_id)
    s.order_id,

    -- Tipo de pagamento principal do pedido
    p.primary_payment_type,

    -- Atributos consolidados
    s.total_payment_value,
    s.max_installments,
    s.payment_methods_count,
    s.is_split_payment

FROM payment_summary s

LEFT JOIN primary_payment p
    ON s.order_id = p.order_id
    AND p.rn = 1
