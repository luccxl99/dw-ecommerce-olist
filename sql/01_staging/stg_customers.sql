-- =============================================================================
-- STAGING: stg_customers
-- Fonte: customers (tabela bruta carregada do CSV)
-- Descrição: Informações dos clientes.
--            Atenção: customer_id é gerado por pedido — o mesmo cliente físico
--            pode ter IDs diferentes em pedidos diferentes.
--            customer_unique_id é o identificador real e único do cliente.
-- =============================================================================

CREATE OR REPLACE VIEW `olistdbt.staging.stg_customers` AS

SELECT
    -- ID gerado por pedido (não representa unicidade do cliente)
    customer_id,

    -- ID único real do cliente — use este para análises de comportamento
    customer_unique_id,

    -- CEP (primeiros 5 dígitos) para cruzar com geolocalização
    CAST(customer_zip_code_prefix AS STRING) AS customer_zip_code_prefix,

    -- Cidade e estado: TRIM remove espaços extras comuns em CSVs
    -- INITCAP padroniza capitalização (ex: "sao paulo" → "Sao Paulo")
    INITCAP(TRIM(customer_city))  AS customer_city,
    UPPER(TRIM(customer_state))   AS customer_state

FROM `olistdbt.raw.customers`

WHERE customer_id        IS NOT NULL
  AND customer_unique_id IS NOT NULL
