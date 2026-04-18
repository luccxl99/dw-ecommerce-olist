-- =============================================================================
-- STAGING: stg_sellers
-- Fonte: olist_sellers_dataset (tabela bruta carregada do CSV)
-- Descrição: Informações dos vendedores cadastrados na plataforma Olist.
-- =============================================================================

CREATE OR REPLACE VIEW `your_project.staging.stg_sellers` AS

SELECT
    -- Identificador único do vendedor
    seller_id,

    -- CEP para cruzar com geolocalização
    CAST(seller_zip_code_prefix AS STRING) AS seller_zip_code_prefix,

    -- Mesma padronização de cidade/estado aplicada nos clientes
    INITCAP(TRIM(seller_city))  AS seller_city,
    UPPER(TRIM(seller_state))   AS seller_state

FROM `your_project.raw.olist_sellers_dataset`

WHERE seller_id IS NOT NULL
