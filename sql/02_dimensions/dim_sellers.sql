-- =============================================================================
-- DIMENSÃO: dim_sellers
-- Fonte: stg_sellers + stg_geolocation
-- Descrição: Dimensão de vendedores cadastrados na plataforma Olist.
--            Enriquecemos com coordenadas geográficas via CEP, igual ao
--            que fizemos com clientes.
-- =============================================================================

CREATE OR REPLACE TABLE `your_project.dimensions.dim_sellers` AS

SELECT
    -- Chave surrogate: hash determinístico da chave natural
    FARM_FINGERPRINT(s.seller_id) AS seller_sk,

    -- Chave natural
    s.seller_id,

    -- Atributos descritivos do vendedor
    s.seller_city,
    s.seller_state,

    -- Coordenadas geográficas enriquecidas
    g.latitude  AS seller_latitude,
    g.longitude AS seller_longitude

FROM `your_project.staging.stg_sellers` s

LEFT JOIN `your_project.staging.stg_geolocation` g
    ON s.seller_zip_code_prefix = g.zip_code_prefix
