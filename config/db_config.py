import os

DB_CONFIG = {
    "dbname": os.getenv("POSTGRES_DB", "healthcare"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "host": os.getenv("POSTGRES_HOST", "db"),
    "port": int(os.getenv("POSTGRES_PORT", 5432)),
}
