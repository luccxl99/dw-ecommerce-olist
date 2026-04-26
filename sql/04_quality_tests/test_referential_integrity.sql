-- =============================================================================
-- TESTES DE QUALIDADE: Integridade referencial
-- Descrição: Verifica se todas as FKs da fato apontam para registros
--            que existem nas dimensões. Um FK "órfão" significa que a fato
--            tem uma linha que não consegue ser enriquecida com contexto
--            da dimensão correspondente.
--            Um teste passa quando retorna 0 linhas.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TEST 1: fct_orders.customer_sk deve existir em dim_customers
-- -----------------------------------------------------------------------------
SELECT
    'fct_orders → dim_customers' AS relacionamento,
    COUNT(*)                     AS fks_orfas
FROM `olistdbt.facts.fct_orders` f
LEFT JOIN `olistdbt.dimensions.dim_customers` d
    ON f.customer_sk = d.customer_sk
WHERE d.customer_sk IS NULL

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 2: fct_orders.seller_sk deve existir em dim_sellers
-- -----------------------------------------------------------------------------
SELECT
    'fct_orders → dim_sellers',
    COUNT(*)
FROM `olistdbt.facts.fct_orders` f
LEFT JOIN `olistdbt.dimensions.dim_sellers` d
    ON f.seller_sk = d.seller_sk
WHERE d.seller_sk IS NULL

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 3: fct_orders.product_sk deve existir em dim_products
-- -----------------------------------------------------------------------------
SELECT
    'fct_orders → dim_products',
    COUNT(*)
FROM `olistdbt.facts.fct_orders` f
LEFT JOIN `olistdbt.dimensions.dim_products` d
    ON f.product_sk = d.product_sk
WHERE d.product_sk IS NULL

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 4: fct_orders.date_sk deve existir em dim_date
-- -----------------------------------------------------------------------------
SELECT
    'fct_orders → dim_date',
    COUNT(*)
FROM `olistdbt.facts.fct_orders` f
LEFT JOIN `olistdbt.dimensions.dim_date` d
    ON f.date_sk = d.date_sk
WHERE d.date_sk IS NULL
