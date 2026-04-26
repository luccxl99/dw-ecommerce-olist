-- =============================================================================
-- DIMENSÃO: dim_products
-- Fonte: stg_products
-- Descrição: Dimensão de produtos cadastrados na plataforma Olist.
--            Inclui categoria (em inglês, padrão para portfólio público)
--            e atributos físicos usados para análises de frete.
-- =============================================================================

CREATE OR REPLACE TABLE `olistdbt.dimensions.dim_products` AS

SELECT
    -- Chave surrogate
    FARM_FINGERPRINT(product_id) AS product_sk,

    -- Chave natural
    product_id,

    -- Categoria do produto
    product_category_name_pt,
    product_category_name_en,

    -- Atributos de conteúdo do anúncio
    product_name_length,
    product_description_length,
    product_photos_qty,

    -- Dimensões físicas — relevantes para análise de custo de frete
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm

FROM `olistdbt.staging.stg_products`
