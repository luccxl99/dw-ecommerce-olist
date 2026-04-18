-- =============================================================================
-- STAGING: stg_products
-- Fonte: olist_products_dataset + product_category_name_translation
-- Descrição: Produtos cadastrados na plataforma.
--            Fazemos aqui um JOIN com a tabela de tradução de categorias
--            para já trazer o nome da categoria em inglês — padrão mais
--            universal para um portfólio público no GitHub.
-- =============================================================================

CREATE OR REPLACE VIEW `your_project.staging.stg_products` AS

SELECT
    -- Identificador único do produto
    p.product_id,

    -- Categoria em português (original) e inglês (traduzida)
    p.product_category_name                             AS product_category_name_pt,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_en,

    -- Métricas descritivas do produto — convertidas de STRING para numérico
    CAST(p.product_name_lenght        AS INT64)   AS product_name_length,
    CAST(p.product_description_lenght AS INT64)   AS product_description_length,
    CAST(p.product_photos_qty         AS INT64)   AS product_photos_qty,

    -- Dimensões físicas (usadas para calcular frete)
    CAST(p.product_weight_g   AS FLOAT64) AS product_weight_g,
    CAST(p.product_length_cm  AS FLOAT64) AS product_length_cm,
    CAST(p.product_height_cm  AS FLOAT64) AS product_height_cm,
    CAST(p.product_width_cm   AS FLOAT64) AS product_width_cm

FROM `your_project.raw.olist_products_dataset` p

-- LEFT JOIN para não perder produtos sem tradução de categoria
LEFT JOIN `your_project.raw.product_category_name_translation` t
    ON p.product_category_name = t.product_category_name

WHERE p.product_id IS NOT NULL
