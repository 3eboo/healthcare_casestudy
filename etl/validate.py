import logging
from typing import List, Dict

from etl.utils import is_valid_date_format, is_valid_code

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)


def validate_patients(patients: List) -> List:
    return [p for p in patients if (p['patient_id'] and p['masked_name'])]


def validate_visits(visits: List[Dict]) -> List:
    return [v for v in visits if
            (v['visit_id'] and v['patient_id'] and is_valid_date_format(v['visit_date']))]


def validate_diagnoses(diagnoses) -> List:
    return [d for d in diagnoses if (d['diagnoses_id'] and d['visit_id'] and is_valid_code(d['code']))]


def validate_treatments(treatments) -> List:
    return [t for t in treatments if (t['treatment_id'] and t['diagnoses_id'] and t['drug'])]

