import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()


def build_database_url(database=None):
    """
    Construye la URL de conexión a PostgreSQL
    utilizando las variables definidas en .env.
    """
    return URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        database=database or os.getenv("DB_NAME"),
    )


def get_engine(database=None):
    """
    Crea y devuelve un engine de SQLAlchemy.
    """
    database_url = build_database_url(database)

    return create_engine(
        database_url,
        pool_pre_ping=True,
    )
