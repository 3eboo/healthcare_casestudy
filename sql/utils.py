import logging

import psycopg2
from config.db_config import DB_CONFIG
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)

def apply_sql_file(sql_file_path: str="sql/views.sql"):
    """Run an arbitrary SQL file (e.g., views.sql) after ETL is done."""
    with open(sql_file_path, 'r') as f:
        sql_code = f.read()

    # Split on semicolon only if not inside a string (handles multi-statement files)
    statements = [s.strip() for s in sql_code.split(';') if s.strip()]

    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                for stmt in statements:
                    cur.execute(stmt)
            conn.commit()
        logger.info(f"[SUCCESS] Applied SQL file: {sql_file_path}")
    except Exception:
        logger.exception(f"[ERROR] Failed to apply {sql_file_path}:")
        raise
