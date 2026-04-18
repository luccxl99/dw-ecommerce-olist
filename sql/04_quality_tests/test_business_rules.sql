-- =============================================================================
-- TESTES DE QUALIDADE: Regras de negócio
-- Descrição: Verifica se os dados respeitam regras que fazem sentido
--            para o domínio do e-commerce. Valores que violam essas regras
--            podem indicar erros no pipeline ou na origem dos dados.
--            Um teste passa quando retorna 0 linhas.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TEST 1: Preço e frete não podem ser negativos
-- -----------------------------------------------------------------------------
SELECT
    'item_price negativo' AS regra,
    COUNT(*)              AS violacoes
FROM `your_project.facts.fct_orders`
WHERE item_price < 0

UNION ALL

SELECT
    'item_freight_value negativo',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE item_freight_value < 0

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 2: Valor total do pagamento não pode ser zero ou negativo
-- -----------------------------------------------------------------------------
SELECT
    'total_payment_value <= 0',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE total_payment_value <= 0

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 3: Data de entrega não pode ser anterior à data de compra
-- -----------------------------------------------------------------------------
SELECT
    'entrega antes da compra',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE order_delivered_customer_date < order_purchase_timestamp
  AND order_delivered_customer_date IS NOT NULL

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 4: Data de aprovação não pode ser anterior à data de compra
-- -----------------------------------------------------------------------------
SELECT
    'aprovacao antes da compra',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE order_approved_at < order_purchase_timestamp
  AND order_approved_at IS NOT NULL

UNION ALL

-- -----------------------------------------------------------------------------
-- TEST 5: Pedidos entregues devem ter data de entrega preenchida
-- -----------------------------------------------------------------------------
SELECT
    'pedido delivered sem data de entrega',
    COUNT(*)
FROM `your_project.facts.fct_orders`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL
