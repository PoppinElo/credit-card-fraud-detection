import re
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

from src.database.connection import build_database_url

load_dotenv()


def create_database():
    database_name = os.getenv("DB_NAME")

    if not database_name:
        raise ValueError("DB_NAME no está definido en el archivo .env")

    # Validar el nombre antes de utilizarlo como identificador SQL.
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", database_name):
        raise ValueError("El nombre de la base de datos no es válido.")

    # Conectarse a la base de mantenimiento, no a la que queremos crear.
    maintenance_url = build_database_url(database="postgres")

    engine = create_engine(
        maintenance_url,
        isolation_level="AUTOCOMMIT",
        pool_pre_ping=True,
    )

    try:
        with engine.connect() as connection:

            result = connection.execute(
                text(
                    "SELECT 1 FROM pg_database "
                    "WHERE datname = :database_name"
                ),
                {"database_name": database_name},
            )

            if result.scalar():
                print(f"La base de datos '{database_name}' ya existe.")
            else:
                connection.exec_driver_sql(
                    f'CREATE DATABASE "{database_name}"'
                )
                print(f"Base de datos '{database_name}' creada correctamente.")

    finally:
        engine.dispose()


if __name__ == "__main__":
    create_database()
