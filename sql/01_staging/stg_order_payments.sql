-- =============================================================================
-- STAGING: stg_order_payments
-- Fonte: order_payments (tabela bruta carregada do CSV)
-- Descrição: Pagamentos de cada pedido.
--            Um pedido pode ter múltiplas formas de pagamento (ex: cartão + voucher).
--            Granularidade: 1 linha = 1 forma de pagamento de 1 pedido.
-- =============================================================================

CREATE OR REPLACE VIEW `olistdbt.staging.stg_order_payments` AS

SELECT
    -- Identificador do pedido
    order_id,

    -- Sequência do pagamento quando há mais de um por pedido
    CAST(payment_sequential    AS INT64)   AS payment_sequential,

    -- Tipo do pagamento: credit_card, boleto, voucher, debit_card
    LOWER(TRIM(payment_type))              AS payment_type,

    -- Número de parcelas (1 = à vista)
    CAST(payment_installments  AS INT64)   AS payment_installments,

    -- Valor pago nesta forma de pagamento específica
    CAST(payment_value         AS FLOAT64) AS payment_value

FROM `olistdbt.raw.order_payments`

WHERE order_id IS NOT NULL
