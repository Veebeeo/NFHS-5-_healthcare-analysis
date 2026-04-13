-- 1. Maternal Health View
DROP VIEW IF EXISTS nfhs.vw_maternal_health;
CREATE VIEW nfhs.vw_maternal_health AS
SELECT state, district_id, district_name, region, anc_first_trimester, anc_4plus_visits, institutional_births, skilled_birth_attendance, postnatal_care_mother, ifa_180_days, csection_rate, oop_delivery_cost_rs,
ROUND((COALESCE(anc_first_trimester, 0) * 0.15 + COALESCE(anc_4plus_visits, 0) * 0.15 + COALESCE(institutional_births, 0) * 0.20 + COALESCE(skilled_birth_attendance, 0) * 0.20 + COALESCE(postnatal_care_mother, 0) * 0.15 + COALESCE(ifa_180_days, 0) * 0.15)::NUMERIC, 1) AS maternal_health_score
FROM nfhs.district_health_wide;

-- 2. Child Nutrition View
DROP VIEW IF EXISTS nfhs.vw_child_nutrition;
CREATE VIEW nfhs.vw_child_nutrition AS
SELECT state, district_id, district_name, region, child_stunting, child_wasting, child_severe_wasting, child_underweight, child_overweight, anaemia_children, exclusive_breastfeeding, early_breastfeeding, children_adequate_diet,
CASE WHEN child_stunting > 40 AND anaemia_children > 60 THEN 'CRITICAL' WHEN child_stunting > 30 OR anaemia_children > 50 THEN 'HIGH RISK' WHEN child_stunting > 20 OR anaemia_children > 40 THEN 'MODERATE' ELSE 'LOW RISK' END AS nutrition_risk_category
FROM nfhs.district_health_wide;

-- 3. Anaemia Overview
DROP VIEW IF EXISTS nfhs.vw_anaemia_overview;
CREATE VIEW nfhs.vw_anaemia_overview AS
SELECT state, district_id, district_name, region, anaemia_children, anaemia_all_women, anaemia_pregnant_women, anaemia_nonpregnant_women,
ROUND((COALESCE(anaemia_children, 0) + COALESCE(anaemia_all_women, 0) + COALESCE(anaemia_pregnant_women, 0))::NUMERIC / 3, 1) AS avg_anaemia_burden,
CASE WHEN COALESCE(anaemia_children, 0) > 60 AND COALESCE(anaemia_all_women, 0) > 55 THEN 'SEVERE' WHEN COALESCE(anaemia_children, 0) > 40 OR COALESCE(anaemia_all_women, 0) > 45 THEN 'MODERATE' ELSE 'MILD' END AS anaemia_severity
FROM nfhs.district_health_wide;

-- 4. District Composite Score
DROP VIEW IF EXISTS nfhs.vw_district_health_score;
CREATE VIEW nfhs.vw_district_health_score AS
SELECT state, district_id, district_name, region,
ROUND((COALESCE(institutional_births, 0) * 0.10 + COALESCE(full_vaccination, 0) * 0.10 + COALESCE(anc_4plus_visits, 0) * 0.10 + (100 - COALESCE(child_stunting, 50)) * 0.15 + (100 - COALESCE(child_wasting, 30)) * 0.15 + (100 - COALESCE(anaemia_children, 70)) * 0.10 + (100 - COALESCE(anaemia_all_women, 60)) * 0.10 + COALESCE(hh_improved_sanitation, 0) * 0.10 + COALESCE(hh_clean_fuel, 0) * 0.10)::NUMERIC / 100, 1) AS composite_health_score
FROM nfhs.district_health_wide;