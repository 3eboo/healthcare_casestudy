-- ========================================================================
-- Patients prescriped Metformin in q2 2023
-- ========================================================================
CREATE OR REPLACE VIEW patients_metformin_q2_2023 AS
SELECT
    p.patient_id,
    p.masked_name,
    v.visit_date,
    t.drug,
    t.dose
FROM patients p
JOIN visits_2023 v ON p.patient_id = v.patient_id
JOIN diagnoses d ON v.visit_id = d.visit_id
JOIN treatments t ON d.diagnoses_id = t.diagnoses_id
WHERE
    t.drug ILIKE 'Metformin'
    AND v.visit_date >= '2023-04-01'
    AND v.visit_date < '2023-07-01';


-- ========================================================================
-- Patient Dashboard: Fast summary per patient (visits, diagnoses, last seen)
-- ========================================================================
CREATE MATERIALIZED VIEW patient_dashboard AS
SELECT
    p.patient_id,
    p.masked_name,
    COALESCE(COUNT(DISTINCT v.visit_id), 0) AS total_visits,
    COALESCE(COUNT(DISTINCT d.diagnoses_id), 0) AS total_diagnoses,
    COALESCE(COUNT(DISTINCT t.treatment_id), 0) AS total_treatments,
    MAX(v.visit_date) AS last_visit_date
FROM
    patients p
LEFT JOIN visits v ON v.patient_id = p.patient_id
LEFT JOIN diagnoses d ON d.visit_id = v.visit_id
LEFT JOIN treatments t ON t.diagnoses_id = d.diagnoses_id
GROUP BY p.patient_id, p.masked_name;

-- ========================================================================
-- Patient Visit History: Flattened, business-friendly. One row per diagnosis.
-- ========================================================================
CREATE VIEW patient_visit_history AS
SELECT
    p.patient_id,
    p.masked_name,
    v.visit_id,
    v.visit_date,
    d.code AS diagnoses_code,
    d.description AS diagnoses_description,
    t.drug,
    t.dose
FROM
    patients p
JOIN
    visits v ON v.patient_id = p.patient_id
JOIN
    diagnoses d ON d.visit_id = v.visit_id
LEFT JOIN
    treatments t ON t.diagnoses_id = d.diagnoses_id;

-- ========================================================================
-- Diagnoses Frequency: For BI bar charts of "top diagnoses"
-- ========================================================================
CREATE VIEW diagnoses_frequency AS
SELECT
    d.code AS diagnoses_code,
    d.description,
    COUNT(*) AS diagnoses_count
FROM
    diagnoses d
GROUP BY
    d.code, d.description
ORDER BY
    diagnoses_count DESC;

-- ========================================================================
-- Recent Patient Encounters: All patient visits in the last 30 days
-- ========================================================================
CREATE VIEW recent_patient_encounters AS
SELECT
    v.visit_id,
    v.patient_id,
    p.masked_name,
    v.visit_date,
    v.provider_note_author,
    v.provider_note_text
FROM
    visits v
JOIN
    patients p ON p.patient_id = v.patient_id
WHERE
    v.visit_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY
    v.visit_date DESC;


-- ========================================================================
-- Patients With Multiple Chronic Conditions: (adjust codes as needed)
-- ========================================================================
CREATE VIEW patients_multiple_chronic_conditions AS
SELECT
    p.patient_id,
    p.masked_name,
    COUNT(DISTINCT d.code) AS num_chronic_diagnoses
FROM
    patients p
JOIN
    visits v ON v.patient_id = p.patient_id
JOIN
    diagnoses d ON d.visit_id = v.visit_id
WHERE
    d.code IN ('ICD-10:E11.9', 'ICD-10:I10', 'ICD-10:J45.909')
GROUP BY
    p.patient_id, p.masked_name
HAVING
    COUNT(DISTINCT d.code) > 1;
