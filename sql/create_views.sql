-- NFHS HEALTH ANALYTICS — ANALYTICAL VIEWS

-- VIEW 1: Maternal Health Scorecard
-- Key indicators for maternal care by district

DROP VIEW IF EXISTS nfhs.vw_maternal_health;

CREATE VIEW nfhs.vw_maternal_health AS
SELECT
    state,
    district_name,
    region,
    anc_first_trimester,
    anc_4plus_visits,
    institutional_births,
    skilled_birth_attendance,
    postnatal_care_mother,
    ifa_180_days,
    csection_rate,
    oop_delivery_cost_rs,
    -- Composite score (0-100 scale)
    ROUND(
        (
            COALESCE(anc_first_trimester, 0) * 0.15 +
            COALESCE(anc_4plus_visits, 0) * 0.15 +
            COALESCE(institutional_births, 0) * 0.20 +
            COALESCE(skilled_birth_attendance, 0) * 0.20 +
            COALESCE(postnatal_care_mother, 0) * 0.15 +
            COALESCE(ifa_180_days, 0) * 0.15
        )::NUMERIC, 1
    ) AS maternal_health_score
FROM nfhs.district_health_wide
ORDER BY maternal_health_score ASC;

-- VIEW 2: Child Nutrition Dashboard
-- Stunting, wasting, anaemia and feeding practices

DROP VIEW IF EXISTS nfhs.vw_child_nutrition;

CREATE VIEW nfhs.vw_child_nutrition AS
SELECT
    state,
    district_name,
    region,
    child_stunting,
    child_wasting,
    child_severe_wasting,
    child_underweight,
    child_overweight,
    anaemia_children,
    exclusive_breastfeeding,
    early_breastfeeding,
    children_adequate_diet,
    -- Risk category based on stunting + anaemia
    CASE
        WHEN child_stunting > 40 AND anaemia_children > 60 THEN 'CRITICAL'
        WHEN child_stunting > 30 OR anaemia_children > 50 THEN 'HIGH RISK'
        WHEN child_stunting > 20 OR anaemia_children > 40 THEN 'MODERATE'
        ELSE 'LOW RISK'
    END AS nutrition_risk_category
FROM nfhs.district_health_wide
ORDER BY child_stunting DESC NULLS LAST;


-- VIEW 3: Anaemia Overview (all demographics)

DROP VIEW IF EXISTS nfhs.vw_anaemia_overview;

CREATE VIEW nfhs.vw_anaemia_overview AS
SELECT
    state,
    district_name,
    region,
    anaemia_children,
    anaemia_all_women,
    anaemia_pregnant_women,
    anaemia_nonpregnant_women,
    -- Average anaemia burden across all groups
    ROUND(
        (
            COALESCE(anaemia_children, 0) +
            COALESCE(anaemia_all_women, 0) +
            COALESCE(anaemia_pregnant_women, 0)
        )::NUMERIC / 3, 1
    ) AS avg_anaemia_burden,
    CASE
        WHEN COALESCE(anaemia_children, 0) > 60 
             AND COALESCE(anaemia_all_women, 0) > 55 THEN 'SEVERE'
        WHEN COALESCE(anaemia_children, 0) > 40 
             OR COALESCE(anaemia_all_women, 0) > 45 THEN 'MODERATE'
        ELSE 'MILD'
    END AS anaemia_severity
FROM nfhs.district_health_wide
ORDER BY avg_anaemia_burden DESC;

-- VIEW 4: District Composite Health Score
-- Overall health performance ranking

DROP VIEW IF EXISTS nfhs.vw_district_health_score;

CREATE VIEW nfhs.vw_district_health_score AS
SELECT
    state,
    district_name,
    region,
    -- Score components (each normalized to contribute 0-10 points)
    -- Higher score = better health outcomes
    ROUND(
        (
            -- Maternal care (higher is better) — 30 points
            COALESCE(institutional_births, 0) * 0.10 +
            COALESCE(full_vaccination, 0) * 0.10 +
            COALESCE(anc_4plus_visits, 0) * 0.10 +
            -- Child nutrition (lower is better, so invert) — 30 points
            (100 - COALESCE(child_stunting, 50)) * 0.15 +
            (100 - COALESCE(child_wasting, 30)) * 0.15 +
            -- Anaemia (lower is better, so invert) — 20 points
            (100 - COALESCE(anaemia_children, 70)) * 0.10 +
            (100 - COALESCE(anaemia_all_women, 60)) * 0.10 +
            -- Infrastructure — 20 points
            COALESCE(hh_improved_sanitation, 0) * 0.10 +
            COALESCE(hh_clean_fuel, 0) * 0.10
        )::NUMERIC / 100, 1
    ) AS composite_health_score
FROM nfhs.district_health_wide
ORDER BY composite_health_score ASC;


-- VIEW 5: State-Level Summary (aggregated from districts)

DROP VIEW IF EXISTS nfhs.vw_state_summary;

CREATE VIEW nfhs.vw_state_summary AS
SELECT
    state,
    region,
    COUNT(*) AS num_districts,
    -- Maternal
    ROUND(AVG(institutional_births)::NUMERIC, 1) AS avg_institutional_births,
    ROUND(AVG(anc_4plus_visits)::NUMERIC, 1) AS avg_anc_4plus,
    -- Child nutrition
    ROUND(AVG(child_stunting)::NUMERIC, 1) AS avg_stunting,
    ROUND(AVG(child_wasting)::NUMERIC, 1) AS avg_wasting,
    ROUND(AVG(child_underweight)::NUMERIC, 1) AS avg_underweight,
    -- Anaemia
    ROUND(AVG(anaemia_children)::NUMERIC, 1) AS avg_anaemia_children,
    ROUND(AVG(anaemia_all_women)::NUMERIC, 1) AS avg_anaemia_women,
    -- Vaccination
    ROUND(AVG(full_vaccination)::NUMERIC, 1) AS avg_full_vaccination,
    -- Infrastructure
    ROUND(AVG(hh_improved_sanitation)::NUMERIC, 1) AS avg_sanitation,
    ROUND(AVG(hh_clean_fuel)::NUMERIC, 1) AS avg_clean_fuel,
    -- Socioeconomic
    ROUND(AVG(women_10yr_schooling)::NUMERIC, 1) AS avg_women_education
FROM nfhs.district_health_wide
GROUP BY state, region
ORDER BY avg_stunting DESC NULLS LAST;


SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'nfhs'
ORDER BY table_type, table_name;