-- ANALYTICAL QUERIES


-- Q1: Top 20 worst districts by composite health score

SELECT state, district_name, region, composite_health_score
FROM nfhs.vw_district_health_score
ORDER BY composite_health_score ASC
LIMIT 20;



-- Q2: Top 20 best districts by composite health score

SELECT state, district_name, region, composite_health_score
FROM nfhs.vw_district_health_score
ORDER BY composite_health_score DESC
LIMIT 20;



-- Q3: State rankings by average child stunting

SELECT 
    state,
    region,
    num_districts,
    avg_stunting,
    avg_wasting,
    avg_anaemia_children,
    avg_full_vaccination
FROM nfhs.vw_state_summary
ORDER BY avg_stunting DESC NULLS LAST;



-- Q4: Regional health comparison

SELECT 
    region,
    COUNT(*) AS total_districts,
    ROUND(AVG(child_stunting)::NUMERIC, 1) AS avg_stunting,
    ROUND(AVG(child_wasting)::NUMERIC, 1) AS avg_wasting,
    ROUND(AVG(anaemia_children)::NUMERIC, 1) AS avg_anaemia_children,
    ROUND(AVG(institutional_births)::NUMERIC, 1) AS avg_inst_births,
    ROUND(AVG(full_vaccination)::NUMERIC, 1) AS avg_vaccination,
    ROUND(AVG(hh_improved_sanitation)::NUMERIC, 1) AS avg_sanitation
FROM nfhs.district_health_wide
GROUP BY region
ORDER BY avg_stunting DESC;



-- Q5: Districts in CRITICAL nutrition risk

SELECT state, district_name, region, 
       child_stunting, anaemia_children, 
       nutrition_risk_category
FROM nfhs.vw_child_nutrition
WHERE nutrition_risk_category = 'CRITICAL'
ORDER BY child_stunting DESC;



-- Q6: Anaemia paradox — high institutional births but 
--     still high anaemia (possible service quality issue)

SELECT 
    state,
    district_name,
    institutional_births,
    anaemia_children,
    anaemia_all_women,
    full_vaccination
FROM nfhs.district_health_wide
WHERE institutional_births > 90 
  AND anaemia_children > 60
ORDER BY anaemia_children DESC
LIMIT 20;



-- Q7: Best performing districts in the worst performing states
-- ("Hidden Champions")

WITH state_avg AS (
    SELECT state, 
           AVG(child_stunting) AS avg_stunting
    FROM nfhs.district_health_wide
    GROUP BY state
    HAVING AVG(child_stunting) > 35  -- Worst states
)
SELECT 
    w.state,
    w.district_name,
    w.child_stunting,
    sa.avg_stunting AS state_avg_stunting,
    ROUND((sa.avg_stunting - w.child_stunting)::NUMERIC, 1) AS better_than_state_avg
FROM nfhs.district_health_wide w
JOIN state_avg sa ON w.state = sa.state
WHERE w.child_stunting < 30  -- But these districts are doing well
ORDER BY better_than_state_avg DESC
LIMIT 15;



-- Q8: Correlation proxy — Women's education vs stunting
--     (districts grouped by education quartile)

SELECT 
    CASE
        WHEN women_10yr_schooling >= 60 THEN '4_High (60%+)'
        WHEN women_10yr_schooling >= 40 THEN '3_Medium-High (40-60%)'
        WHEN women_10yr_schooling >= 20 THEN '2_Medium-Low (20-40%)'
        ELSE '1_Low (<20%)'
    END AS education_quartile,
    COUNT(*) AS num_districts,
    ROUND(AVG(child_stunting)::NUMERIC, 1) AS avg_stunting,
    ROUND(AVG(anaemia_children)::NUMERIC, 1) AS avg_anaemia,
    ROUND(AVG(institutional_births)::NUMERIC, 1) AS avg_inst_births,
    ROUND(AVG(hh_improved_sanitation)::NUMERIC, 1) AS avg_sanitation
FROM nfhs.district_health_wide
WHERE women_10yr_schooling IS NOT NULL
GROUP BY education_quartile
ORDER BY education_quartile;



-- Q9: Urban-rural proxy — Clean fuel access vs health outcomes

SELECT
    CASE
        WHEN hh_clean_fuel >= 70 THEN '3_High fuel access (70%+)'
        WHEN hh_clean_fuel >= 30 THEN '2_Medium fuel access (30-70%)'
        ELSE '1_Low fuel access (<30%)'
    END AS fuel_access_tier,
    COUNT(*) AS num_districts,
    ROUND(AVG(child_stunting)::NUMERIC, 1) AS avg_stunting,
    ROUND(AVG(anaemia_children)::NUMERIC, 1) AS avg_anaemia,
    ROUND(AVG(full_vaccination)::NUMERIC, 1) AS avg_vaccination,
    ROUND(AVG(women_10yr_schooling)::NUMERIC, 1) AS avg_women_edu
FROM nfhs.district_health_wide
WHERE hh_clean_fuel IS NOT NULL
GROUP BY fuel_access_tier
ORDER BY fuel_access_tier;



-- Q10: Worst 10 districts per indicator (using long format)
-- Example: worst 10 districts for child stunting

SELECT 
    state, district_name, nfhs5_value AS child_stunting_pct
FROM nfhs.fact_health_long
WHERE indicator_short = 'child_stunting'
  AND nfhs5_value IS NOT NULL
ORDER BY nfhs5_value DESC
LIMIT 10;



-- Q11: NFHS-4 vs NFHS-5 — States that improved most in stunting

SELECT 
    state,
    ROUND(AVG(nfhs4_value)::NUMERIC, 1) AS avg_stunting_nfhs4,
    ROUND(AVG(nfhs5_value)::NUMERIC, 1) AS avg_stunting_nfhs5,
    ROUND(AVG(change)::NUMERIC, 1) AS avg_improvement
FROM nfhs.fact_health_long
WHERE indicator_short = 'child_stunting'
  AND nfhs5_value IS NOT NULL
  AND nfhs4_value IS NOT NULL
GROUP BY state
ORDER BY avg_improvement DESC;



-- Q12: Districts where anaemia WORSENED from NFHS-4 to NFHS-5

SELECT 
    state, district_name, 
    nfhs4_value AS anaemia_nfhs4,
    nfhs5_value AS anaemia_nfhs5,
    change AS worsened_by
FROM nfhs.fact_health_long
WHERE indicator_short = 'anaemia_children'
  AND change < 0  -- Negative change = got worse (higher anaemia)
ORDER BY change ASC
LIMIT 20;



-- Q13: Count of indicators per category

SELECT 
    category, 
    COUNT(DISTINCT indicator_short) AS num_indicators
FROM nfhs.fact_health_long
GROUP BY category
ORDER BY num_indicators DESC;



-- Q14: State-wise maternal health scores (from view)

SELECT 
    state,
    COUNT(*) AS districts,
    ROUND(AVG(maternal_health_score)::NUMERIC, 1) AS avg_maternal_score,
    ROUND(MIN(maternal_health_score)::NUMERIC, 1) AS worst_district,
    ROUND(MAX(maternal_health_score)::NUMERIC, 1) AS best_district
FROM nfhs.vw_maternal_health
GROUP BY state
ORDER BY avg_maternal_score ASC;



-- Q15: Sanitation vs stunting — district level scatter data

SELECT 
    state,
    district_name,
    region,
    hh_improved_sanitation,
    child_stunting,
    anaemia_children,
    women_10yr_schooling,
    institutional_births
FROM nfhs.district_health_wide
WHERE child_stunting IS NOT NULL 
  AND hh_improved_sanitation IS NOT NULL
ORDER BY hh_improved_sanitation;