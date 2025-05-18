CREATE OR REPLACE VIEW patients_metformin_q2_2023 AS
SELECT
    p.patient_id,
    p.masked_name,
    v.visit_date,
    t.drug,
    t.dose
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN diagnoses d ON v.visit_id = d.visit_id
JOIN treatments t ON d.diagnoses_id = t.diagnoses_id
WHERE
    t.drug ILIKE 'Metformin'
    AND v.visit_date BETWEEN '2023-04-01' AND '2023-06-30';


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


CREATE MATERIALIZED VIEW patient_dashboard AS
SELECT
    p.patient_id,
    p.masked_name,
    COUNT(DISTINCT v.visit_id) AS total_visits,
    COUNT(DISTINCT d.diagnoses_id) AS total_diagnoses,
    COUNT(DISTINCT t.treatment_id) AS total_treatments,
    MAX(v.visit_date) AS last_visit_date
FROM
    patients p
LEFT JOIN
    visits v ON v.patient_id = p.patient_id
LEFT JOIN
    diagnoses d ON d.visit_id = v.visit_id
LEFT JOIN
    treatments t ON t.diagnoses_id = d.diagnoses_id
GROUP BY
    p.patient_id, p.masked_name;


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
    d.code IN ('ICD-10:E11.9', 'ICD-10:I10', 'ICD-10:J45.909' /*add codes as needed*/)
GROUP BY
    p.patient_id, p.masked_name
HAVING
    COUNT(DISTINCT d.code) > 1;
