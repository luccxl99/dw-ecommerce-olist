-- =============================================================================
-- STAGING: stg_geolocation
-- Fonte: olist_geolocation_dataset (tabela bruta carregada do CSV)
-- Descrição: Coordenadas geográficas por CEP.
--            Este dataset tem MUITAS linhas duplicadas por CEP (múltiplas
--            coordenadas para o mesmo CEP). Aqui já resolvemos isso tirando
--            a média das coordenadas por CEP — uma coordenada representativa.
-- =============================================================================

CREATE OR REPLACE VIEW `your_project.staging.stg_geolocation` AS

SELECT
    CAST(geolocation_zip_code_prefix AS STRING) AS zip_code_prefix,
    UPPER(TRIM(geolocation_state))              AS state,
    INITCAP(TRIM(geolocation_city))             AS city,

    -- Média das coordenadas para ter 1 ponto representativo por CEP
    AVG(CAST(geolocation_lat AS FLOAT64))       AS latitude,
    AVG(CAST(geolocation_lng AS FLOAT64))       AS longitude

FROM `your_project.raw.olist_geolocation_dataset`

WHERE geolocation_zip_code_prefix IS NOT NULL

-- Agrupamos por CEP para eliminar as duplicatas do dataset original
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_state,
    geolocation_city
