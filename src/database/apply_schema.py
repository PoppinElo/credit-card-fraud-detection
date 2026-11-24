from pathlib import Path

from src.database.connection import get_engine


PROJECT_ROOT = Path(__file__).resolve().parents[2]
SCHEMA_FILE = PROJECT_ROOT / "sql" / "schema.sql"


def apply_schema():
    """Ejecuta el archivo schema.sql en PostgreSQL."""

    if not SCHEMA_FILE.exists():
        raise FileNotFoundError(
            f"No se encontró el archivo: {SCHEMA_FILE}"
        )

    sql_script = SCHEMA_FILE.read_text(encoding="utf-8")

    engine = get_engine()

    try:
        with engine.begin() as connection:
            connection.exec_driver_sql(sql_script)

        print("Esquema SQL aplicado correctamente.")

    finally:
        engine.dispose()


if __name__ == "__main__":
    apply_schema()
