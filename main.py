from etl.extract import extract_json
from etl.flatten import flatten_records
from etl.load import insert_records
from etl.validate import *

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    data = extract_json("data/patient_data.json")
    patients, visits, diagnoses, treatments = flatten_records(data)

    insert_records(
        validate_patients(patients), "patients", ["patient_id", "masked_name"])

    insert_records(
        validate_visits(visits), "visits",
        ["visit_id", "patient_id", "visit_date", "provider_note_text", "provider_note_author"])

    insert_records(
        validate_diagnoses(diagnoses), "diagnoses",
        ["diagnoses_id", "visit_id", "code", "description"])

    insert_records(
        validate_treatments(treatments), "treatments",
        ["treatment_id", "diagnoses_id", "drug", "dose"])

    logger.info("ETL process completed successfully.")
