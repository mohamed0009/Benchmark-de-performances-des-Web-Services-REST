-- ============================================================================
-- Benchmark de performances des Web Services REST
-- Prof. LACHGAR - Modèle de données complet
-- PostgreSQL 14+
-- ============================================================================

-- Drop existing tables
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS category CASCADE;

-- ============================================================================
-- TABLE: category
-- ============================================================================
CREATE TABLE category (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(32) UNIQUE NOT NULL,
    name          VARCHAR(128) NOT NULL,
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE: item
-- ============================================================================
CREATE TABLE item (
    id            BIGSERIAL PRIMARY KEY,
    sku           VARCHAR(64) UNIQUE NOT NULL,
    name          VARCHAR(128) NOT NULL,
    price         NUMERIC(10,2) NOT NULL,
    stock         INT NOT NULL,
    category_id   BIGINT NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES (Performance optimization)
-- ============================================================================
CREATE INDEX idx_item_category   ON item(category_id);
CREATE INDEX idx_item_updated_at ON item(updated_at);
CREATE INDEX idx_category_code   ON category(code);

-- ============================================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_category_updated_at BEFORE UPDATE ON category
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_updated_at BEFORE UPDATE ON item
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- DATA GENERATION: 2,000 Categories (CAT0001 to CAT2000)
-- ============================================================================
INSERT INTO category (code, name, updated_at)
SELECT 
    'CAT' || LPAD(generate_series::TEXT, 4, '0'),
    'Category ' || generate_series,
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 2000);

-- ============================================================================
-- DATA GENERATION: 100,000 Items (~50 items per category)
-- ============================================================================
INSERT INTO item (sku, name, price, stock, category_id, updated_at)
SELECT 
    'SKU' || LPAD(generate_series::TEXT, 6, '0'),
    'Item ' || generate_series,
    ROUND((random() * 999 + 1)::numeric, 2),
    FLOOR(random() * 1000 + 1)::INT,
    FLOOR(random() * 2000 + 1)::BIGINT,
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 100000);

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO benchmark_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO benchmark_user;

-- ============================================================================
-- VACUUM ANALYZE (Optimize query planner)
-- ============================================================================
VACUUM ANALYZE category;
VACUUM ANALYZE item;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 'Categories' AS table_name, COUNT(*) AS count FROM category
UNION ALL
SELECT 'Items' AS table_name, COUNT(*) AS count FROM item;
