import logging
from typing import Optional, List, Dict, Any

import psycopg2
from psycopg2 import sql
from psycopg2.extensions import connection as Psycopg2Connection

from config.db_config import DB_CONFIG

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)


def get_connection() -> Optional[Psycopg2Connection]:
    """Establish a database connection using DB_CONFIG."""
    try:
        return psycopg2.connect(**DB_CONFIG)
    except Exception:
        logger.exception(f"Database connection error:")
        raise


def prepare_insert_query(table_name: str, columns: List[str]):
    """Construct a parameterized INSERT SQL statement."""
    col_names = sql.SQL(', ').join(map(sql.Identifier, columns))
    placeholders = sql.SQL(', ').join(sql.Placeholder() * len(columns))

    return sql.SQL("""
        INSERT INTO {table} ({fields})
        VALUES ({values})
        ON CONFLICT DO NOTHING;
    """).format(
        table=sql.Identifier(table_name),
        fields=col_names,
        values=placeholders
    )


def insert_records(data: List[Dict[str, Any]], table_name: str, columns: List[str]) -> None:
    """Insert multiple records into the specified table."""
    if not data:
        logger.warning(f"[INFO] No data to insert into {table_name}.")
        return

    query = prepare_insert_query(table_name, columns)

    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                for record in data:
                    values = tuple(record.get(col) for col in columns)
                    cur.execute(query, values)

            conn.commit()
        logger.info(f"[SUCCESS] Inserted {len(data)} records into '{table_name}'.")

    except Exception as e:
        raise RuntimeError(f"[ERROR] Failed to insert into '{table_name}' because {e}")
