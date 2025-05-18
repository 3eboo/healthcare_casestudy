import json
import logging
from typing import List

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)


def extract_json(file_path: str) -> List:
    """Extracts JSON data from file."""
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        return data
    except Exception:
        logger.exception(f"failed to read {file_path}")
        raise
