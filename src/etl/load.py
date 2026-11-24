from sqlalchemy import text

from src.database.connection import get_engine


def load_data(train, test, sample_submission):
    """
    Carga los DataFrames en las tablas correspondientes de PostgreSQL.
    """

    engine = get_engine()

    try:
        with engine.begin() as connection:

            # 1. Vaciar las tablas para permitir una nueva carga
            connection.execute(
                text("""
                    TRUNCATE TABLE
                        raw.sample_submission,
                        raw.train,
                        raw.test;
                """)
            )

            print("Tablas vaciadas correctamente.")

            # 2. Cargar train
            train.to_sql(
                name="train",
                con=connection,
                schema="raw",
                if_exists="append",
                index=False,
                chunksize=10_000,
            )

            print(f"Train cargado: {len(train):,} registros.")

            # 3. Cargar test
            test.to_sql(
                name="test",
                con=connection,
                schema="raw",
                if_exists="append",
                index=False,
                chunksize=10_000,
            )

            print(f"Test cargado: {len(test):,} registros.")

            # 4. Cargar sample_submission
            sample_submission.to_sql(
                name="sample_submission",
                con=connection,
                schema="raw",
                if_exists="append",
                index=False,
                chunksize=10_000,
            )

            print(
                "Sample submission cargado: "
                f"{len(sample_submission):,} registros."
            )

        print("\nCarga completada correctamente.")

    finally:
        engine.dispose()
