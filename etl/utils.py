import hashlib
import os
import re
from datetime import datetime


def is_valid_date_format(date_str: str) -> bool:
    try:
        datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False


def is_valid_code(code: str) -> bool:
    return bool(re.match(r"^ICD-10:[A-Z]\d{2}(\.\d{1,2})?$", code))


def mask_name(name: str) -> str:
    """Return a SHA256-based pseudonymized version of the name."""
    salt = os.getenv("MASK_SALT")
    return hashlib.sha256((salt + name).encode()).hexdigest()[:12]
