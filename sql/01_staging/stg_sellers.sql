-- =============================================================================
-- STAGING: stg_sellers
-- Fonte: sellers (tabela bruta carregada do CSV)
-- Descrição: Informações dos vendedores cadastrados na plataforma Olist.
-- =============================================================================

CREATE OR REPLACE VIEW `olistdbt.staging.stg_sellers` AS

SELECT
    -- Identificador único do vendedor
    seller_id,

    -- CEP para cruzar com geolocalização
    CAST(seller_zip_code_prefix AS STRING) AS seller_zip_code_prefix,

    -- Mesma padronização de cidade/estado aplicada nos clientes
    INITCAP(TRIM(seller_city))  AS seller_city,
    UPPER(TRIM(seller_state))   AS seller_state

FROM `olistdbt.raw.sellers`

WHERE seller_id IS NOT NULL
