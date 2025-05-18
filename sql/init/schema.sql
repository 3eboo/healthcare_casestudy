
CREATE TABLE IF NOT EXISTS patients (
    patient_id VARCHAR(100) PRIMARY KEY,
    masked_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS visits (
    visit_id VARCHAR(100) NOT NULL,
    patient_id VARCHAR(100) NOT NULL,
    visit_date DATE NOT NULL,
    provider_note_text TEXT,
    provider_note_author TEXT
) PARTITION BY RANGE (visit_date);

--Foreign key to patients is not enforced at DB level for simplicity with partitioning.


CREATE TABLE IF NOT EXISTS visits_2023 PARTITION OF visits
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE IF NOT EXISTS visits_q2_2023 PARTITION OF visits
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

CREATE TABLE IF NOT EXISTS visits_2024 PARTITION OF visits
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Indexes for visits
CREATE INDEX IF NOT EXISTS idx_visits_patient_id ON visits (patient_id);

-- Add primary key to partitions individually for visit_id
ALTER TABLE visits_2023 ADD CONSTRAINT visits_2023_pk PRIMARY KEY (visit_id);
ALTER TABLE visits_2024 ADD CONSTRAINT visits_2024_pk PRIMARY KEY (visit_id);



CREATE TABLE IF NOT EXISTS diagnoses (
    diagnoses_id UUID PRIMARY KEY,
    visit_id VARCHAR(100) NOT NULL,   -- No FK reference due to partitioning constraints
    code VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE INDEX IF NOT EXISTS idx_diagnoses_visit_id ON diagnoses (visit_id);
CREATE INDEX IF NOT EXISTS idx_diagnoses_code ON diagnoses (code);

CREATE TABLE IF NOT EXISTS treatments (
    treatment_id UUID PRIMARY KEY,
    diagnoses_id UUID NOT NULL REFERENCES diagnoses(diagnoses_id),
    drug VARCHAR(255) NOT NULL,
    dose VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_treatments_diagnoses_id ON treatments (diagnoses_id);
CREATE INDEX IF NOT EXISTS idx_treatments_drug ON treatments (drug);