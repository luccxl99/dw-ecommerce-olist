-- =============================================================================
-- DIMENSÃO: dim_sellers
-- Fonte: stg_sellers + stg_geolocation
-- Descrição: Dimensão de vendedores cadastrados na plataforma Olist.
--            Enriquecemos com coordenadas geográficas via CEP, igual ao
--            que fizemos com clientes.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.dimensions.dim_sellers` AS

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

FROM `olistdbt.staging.stg_sellers` s

LEFT JOIN (
    SELECT zip_code_prefix, AVG(latitude) AS latitude, AVG(longitude) AS longitude
    FROM `olistdbt.staging.stg_geolocation`
    GROUP BY zip_code_prefix
) g ON s.seller_zip_code_prefix = g.zip_code_prefix
