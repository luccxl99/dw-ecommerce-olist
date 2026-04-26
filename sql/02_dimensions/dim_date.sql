-- =============================================================================
-- DIMENSÃO: dim_date
-- Fonte: gerada sinteticamente — sem tabela de origem
-- Descrição: Calendário com 1 linha por dia, cobrindo todo o período do dataset
--            Olist (2016 a 2018). Dimensão de data é fundamental em DW pois
--            permite agrupar fatos por dia, mês, trimestre, ano, dia da semana
--            etc. sem precisar fazer EXTRACT() na tabela fato toda vez.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.dimensions.dim_date` AS

WITH date_spine AS (
    -- GENERATE_DATE_ARRAY cria uma sequência de datas dia a dia.
    -- Cobrimos 2016-01-01 até 2018-12-31 — intervalo do dataset Olist.
    SELECT date_day
    FROM UNNEST(
        GENERATE_DATE_ARRAY(DATE '2016-01-01', DATE '2018-12-31', INTERVAL 1 DAY)
    ) AS date_day
)

SELECT
    -- Chave surrogate no formato YYYYMMDD (INT) — padrão comum em DW por ser
    -- legível e eficiente para joins com a tabela fato
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS date_sk,

    -- Data completa (tipo DATE)
    date_day AS full_date,

    -- Componentes da data
    EXTRACT(YEAR       FROM date_day) AS year,
    EXTRACT(QUARTER    FROM date_day) AS quarter,
    EXTRACT(MONTH      FROM date_day) AS month,
    FORMAT_DATE('%B',       date_day) AS month_name,
    FORMAT_DATE('%b',       date_day) AS month_name_short,
    EXTRACT(WEEK       FROM date_day) AS week_of_year,
    EXTRACT(DAY        FROM date_day) AS day_of_month,
    EXTRACT(DAYOFWEEK  FROM date_day) AS day_of_week,       -- 1=Domingo, 7=Sábado
    FORMAT_DATE('%A',       date_day) AS day_name,
    FORMAT_DATE('%a',       date_day) AS day_name_short,

    -- Flags úteis para análises
    CASE WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,

    -- Rótulo de trimestre legível (ex: "2017-Q3")
    CONCAT(CAST(EXTRACT(YEAR FROM date_day) AS STRING), '-Q',
           CAST(EXTRACT(QUARTER FROM date_day) AS STRING)) AS year_quarter,

    -- Rótulo de mês legível (ex: "2017-08")
    FORMAT_DATE('%Y-%m', date_day) AS year_month

FROM date_spine
