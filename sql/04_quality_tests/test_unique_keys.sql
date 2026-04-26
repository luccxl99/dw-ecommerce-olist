-- =============================================================================
-- TESTES DE QUALIDADE: Unicidade das chaves primárias
-- Descrição: Verifica se as chaves primárias são realmente únicas.
--            Chaves duplicadas quebram JOINs — uma linha da fato se
--            multiplicaria ao juntar com uma dimensão com duplicatas.
--            Um teste passa quando retorna 0 linhas.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TEST 1: dim_customers — customer_sk deve ser único
-- -----------------------------------------------------------------------------
SELECT
    'dim_customers.customer_sk' AS chave,
    CAST(customer_sk AS STRING),
    COUNT(*) AS ocorrencias
FROM `olistdbt.dimensions.dim_customers`
GROUP BY customer_sk
HAVING COUNT(*) > 1

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 2: dim_sellers — seller_sk deve ser único
-- -----------------------------------------------------------------------------
SELECT
    'dim_sellers.seller_sk',
    CAST(seller_sk AS STRING),
    COUNT(*)
FROM `olistdbt.dimensions.dim_sellers`
GROUP BY seller_sk
HAVING COUNT(*) > 1

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 3: dim_products — product_sk deve ser único
-- -----------------------------------------------------------------------------
SELECT
    'dim_products.product_sk',
    CAST(product_sk AS STRING),
    COUNT(*)
FROM `olistdbt.dimensions.dim_products`
GROUP BY product_sk
HAVING COUNT(*) > 1

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 4: dim_date — date_sk deve ser único
-- -----------------------------------------------------------------------------
SELECT
    'dim_date.date_sk',
    CAST(date_sk AS STRING),
    COUNT(*)
FROM `olistdbt.dimensions.dim_date`
GROUP BY date_sk
HAVING COUNT(*) > 1

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 5: dim_payments — payment_sk deve ser único
-- -----------------------------------------------------------------------------
SELECT
    'dim_payments.payment_sk',
    CAST(payment_sk AS STRING),
    COUNT(*)
FROM `olistdbt.dimensions.dim_payments`
GROUP BY payment_sk
HAVING COUNT(*) > 1
