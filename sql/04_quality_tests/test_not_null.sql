-- =============================================================================
-- TESTES DE QUALIDADE: Valores nulos em colunas críticas
-- Descrição: Verifica se colunas que não podem ser nulas estão limpas.
--            Um teste passa quando retorna 0 linhas.
--            Se retornar qualquer linha, há um problema de qualidade.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TEST 1: Chaves primárias da fato não podem ser nulas
-- -----------------------------------------------------------------------------
SELECT
    'fct_orders.order_id'  AS coluna,
    COUNT(*)               AS registros_invalidos
FROM `your_project.facts.fct_orders`
WHERE order_id IS NULL

UNION ALL

SELECT
    'fct_orders.customer_sk',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE customer_sk IS NULL

UNION ALL

SELECT
    'fct_orders.product_sk',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE product_sk IS NULL

UNION ALL

SELECT
    'fct_orders.seller_sk',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE seller_sk IS NULL

UNION ALL

SELECT
    'fct_orders.date_sk',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE date_sk IS NULL

-- -----------------------------------------------------------------------------
-- TEST 2: Chaves primárias das dimensões não podem ser nulas
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    'dim_customers.customer_sk',
    COUNT(*)
FROM `your_project.dimensions.dim_customers`
WHERE customer_sk IS NULL

UNION ALL

SELECT
    'dim_sellers.seller_sk',
    COUNT(*)
FROM `your_project.dimensions.dim_sellers`
WHERE seller_sk IS NULL

UNION ALL

SELECT
    'dim_products.product_sk',
    COUNT(*)
FROM `your_project.dimensions.dim_products`
WHERE product_sk IS NULL

UNION ALL

SELECT
    'dim_date.date_sk',
    COUNT(*)
FROM `your_project.dimensions.dim_date`
WHERE date_sk IS NULL
