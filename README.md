# Healthcare Case Study Challenge

## Overview
This solution transforms nested healthcare data into a structured relational model, ensuring it's validated, secure, and ready for BI analysis.

---
## Getting Started

### Prerequisites
- Docker 

To run the project, you can start the container after creating `.env` file having all configs & credentials.
- `make create-env` # creates `.env` file with all variables required.
- `make docker-up` # builds and runs docker compose etl & db containers.



## ETL Pipeline Features

-  Extracts & flattens nested JSON data
-  Validates IDs, dates, ICD coding schemes
-  Loads clean data into PostgreSQL
-  Generates BI-friendly SQL views
-  Handle anonymizes PII (example: masking patient name)

---

## Data Quality Checks

- Verifies non-empty and unique identifiers (`patient_id`, `visit_id`, etc.)
- Ensures valid date formatting (`YYYY-MM-DD`)
- Validates ICD-10 coding pattern
- Drops incomplete or malformed records
- Handles and logs invalid rows (future: can export to quarantine table)

---

## Handling Multi-Source Schema Differences

When aggregating data from multiple hospital systems:

1. **Schema Mapping Layer**: Build a mapping dict or configuration to normalize fields (e.g., `pt_id` → `patient_id`).
2. **Code System Registry**: Maintain mapping tables for local → standard code systems (e.g., SNOMED → ICD-10).
3. **Flexible Transformer**: Use wrappers or custom parsers for each source and normalize to an internal model.
4. **Field Tolerance**: Allow extra fields; ignore unknown fields unless critical.

---

## Security & Compliance

-  PII protection: Masked views for analysts, hashed IDs if needed.
-  Access control: Role-based policies with audit logs.
-  Encryption: TLS for data in transit, disk encryption at rest.
-  HIPAA/GDPR Ready: Data minimization, access logs, patient consent mechanisms.

---

## Performance & Scalability

- Batch reading of json data, could be handled with pandas for medium sized data.
- Eventualy consider paralel distributed processing systems like Spark or Dask for larger scale of batch procesing data.
- An even better aproach is to stream data through Kafka or Spark-streaming.
- Indexes on patient_id, visit_id, drug, code
- Partition large tables by date (e.g., visit date)
- Materialized views for heavy queries


---

## Future Improvements

- Integrate in an orchestration tool in an ideal environlment with several pipelines and bigger environments 
- Integration with Kafka/S3 for real-time ingestion
- Validation log output for invalid rows

