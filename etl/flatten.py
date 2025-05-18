import uuid
from typing import Tuple, List, Dict, Any

from etl.utils import mask_name


def flatten_records(records: List[Dict[str, Any]]) -> Tuple[
    List[Dict[str, Any]],
    List[Dict[str, Any]],
    List[Dict[str, Any]],
    List[Dict[str, Any]]
]:
    patients, visits, diagnoses, treatments = [], [], [], []

    for patient in records:
        patient_id = patient.get("patient_id")
        name = patient.get("name")

        patients.append({
            "patient_id": patient_id,
            "masked_name": mask_name(name)
        })

        for visit in patient.get("visits", []):

            visit_id = visit.get("visit_id")
            visits.append({
                "visit_id": visit_id,
                "patient_id": patient_id,
                "visit_date": visit.get("date"),
                "provider_note_text": visit.get("provider_notes", {}).get("text"),
                "provider_note_author": visit.get("provider_notes", {}).get("author")
            })

            for diagnosis in visit.get("diagnoses", []):
                diagnoses_id = str(uuid.uuid4())
                code = diagnosis.get("code")
                description = diagnosis.get("description")

                diagnoses.append({
                    "diagnoses_id": diagnoses_id,
                    "visit_id": visit_id,
                    "code": code,
                    "description": description
                })

                for treatment in diagnosis.get("treatments", []):
                    treatments.append({
                        "treatment_id": str(uuid.uuid4()),
                        "diagnoses_id": diagnoses_id,
                        "drug": treatment.get("drug"),
                        "dose": treatment.get("dose")
                    })

    return patients, visits, diagnoses, treatments
