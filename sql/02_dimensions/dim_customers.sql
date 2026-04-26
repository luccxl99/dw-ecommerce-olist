-- =============================================================================
-- DIMENSÃO: dim_customers
-- Fonte: stg_customers + stg_geolocation
-- Descrição: Dimensão de clientes únicos.
--            No dataset Olist, customer_id é gerado por pedido — o mesmo
--            cliente físico pode ter vários customer_ids. Aqui usamos
--            customer_unique_id como chave natural e construímos 1 linha
--            por cliente real.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.dimensions.dim_customers` AS

WITH customers_deduped AS (
    -- Um mesmo customer_unique_id pode aparecer em múltiplos pedidos.
    -- ROW_NUMBER garante 1 linha por cliente — pegamos o registro mais recente.
    SELECT
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY customer_id DESC
        ) AS rn
    FROM `olistdbt.staging.stg_customers`
)

SELECT
    -- Chave surrogate: hash determinístico gerado a partir da chave natural.
    -- FARM_FINGERPRINT é nativo do BigQuery — evita depender de ferramentas externas.
    FARM_FINGERPRINT(customer_unique_id) AS customer_sk,

    -- Chave natural: o ID único real do cliente no sistema de origem
    c.customer_unique_id,

    -- Atributos descritivos do cliente
    c.customer_city,
    c.customer_state,

    -- Coordenadas geográficas enriquecidas via JOIN com geolocalização
    g.latitude  AS customer_latitude,
    g.longitude AS customer_longitude

FROM customers_deduped c

LEFT JOIN (
    SELECT zip_code_prefix, AVG(latitude) AS latitude, AVG(longitude) AS longitude
    FROM `olistdbt.staging.stg_geolocation`
    GROUP BY zip_code_prefix
) g ON c.customer_zip_code_prefix = g.zip_code_prefix

WHERE c.rn = 1
