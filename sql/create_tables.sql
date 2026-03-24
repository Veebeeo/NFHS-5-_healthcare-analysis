CREATE SCHEMA IF NOT EXISTS nfhs;

-- TABLE 1: DIMENSION — Districts

DROP TABLE IF EXISTS nfhs.dim_districts CASCADE;

CREATE TABLE nfhs.dim_districts (
    district_row_id     SERIAL PRIMARY KEY,
    state               VARCHAR(100) NOT NULL,
    state_census_code   INTEGER,
    district_name       VARCHAR(100) NOT NULL,
    district_id         VARCHAR(100),
    district_census_code INTEGER,
    region              VARCHAR(20)
);

-- TABLE 2: DIMENSION — Indicators

DROP TABLE IF EXISTS nfhs.dim_indicators CASCADE;

CREATE TABLE nfhs.dim_indicators (
    indicator_row_id    SERIAL PRIMARY KEY,
    short_name          VARCHAR(80) NOT NULL UNIQUE,
    long_name           TEXT NOT NULL,
    category            VARCHAR(100),
    unit                VARCHAR(30),
    higher_is_good      BOOLEAN
);


-- TABLE 3: Long format (district × indicator)

DROP TABLE IF EXISTS nfhs.fact_health_long CASCADE;

CREATE TABLE nfhs.fact_health_long (
    id                  SERIAL PRIMARY KEY,
    state               VARCHAR(100),
    state_census_code   INTEGER,
    district_name       VARCHAR(100),
    district_id         VARCHAR(100),
    district_census_code INTEGER,
    region              VARCHAR(20),
    category            VARCHAR(100),
    indicator           TEXT,
    indicator_short     VARCHAR(80),
    nfhs5_value         DECIMAL(10,2),
    nfhs4_value         DECIMAL(10,2),
    change              DECIMAL(10,2)
);

-- INDEXES for faster querying

CREATE INDEX idx_fact_long_district ON nfhs.fact_health_long(district_name);
CREATE INDEX idx_fact_long_state ON nfhs.fact_health_long(state);
CREATE INDEX idx_fact_long_indicator ON nfhs.fact_health_long(indicator_short);
CREATE INDEX idx_fact_long_category ON nfhs.fact_health_long(category);
CREATE INDEX idx_fact_long_region ON nfhs.fact_health_long(region);
CREATE INDEX idx_dim_districts_state ON nfhs.dim_districts(state);
CREATE INDEX idx_dim_districts_region ON nfhs.dim_districts(region);

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'nfhs'
ORDER BY table_name;