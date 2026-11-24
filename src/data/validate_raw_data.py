from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

TRAIN_FILE = RAW_DATA_DIR / "train.csv"
TEST_FILE = RAW_DATA_DIR / "test.csv"
SUBMISSION_FILE = RAW_DATA_DIR / "sample_submission.csv"


def load_datasets():
    """Comprueba la existencia y carga los archivos CSV."""

    files = [TRAIN_FILE, TEST_FILE, SUBMISSION_FILE]

    for file in files:
        if not file.exists():
            raise FileNotFoundError(f"No se encontró el archivo: {file}")

    train = pd.read_csv(TRAIN_FILE, low_memory=False)
    test = pd.read_csv(TEST_FILE, low_memory=False)
    submission = pd.read_csv(SUBMISSION_FILE, low_memory=False)

    return train, test, submission


def validate_columns(train, test, submission):
    """Comprueba la estructura de columnas de los datasets."""

    print("\n--- VALIDACIÓN DE COLUMNAS ---")

    if "is_fraud" not in train.columns:
        raise ValueError("train.csv no contiene la columna is_fraud.")

    if "is_fraud" in test.columns:
        raise ValueError("test.csv no debería contener is_fraud.")

    if "id" not in train.columns or "id" not in test.columns:
        raise ValueError("Falta la columna id en train o test.")

    train_features = set(train.columns) - {"is_fraud"}
    test_features = set(test.columns)

    if train_features != test_features:
        raise ValueError(
            "Las columnas predictoras de train y test no coinciden."
        )

    expected_submission_columns = {"id", "is_fraud"}

    if set(submission.columns) != expected_submission_columns:
        raise ValueError(
            "sample_submission.csv no tiene las columnas esperadas."
        )

    print("Columnas de train y test: compatibles.")
    print("Columna objetivo: presente solamente en train.")
    print("Formato de submission: correcto.")


def inspect_dataset(name, dataframe):
    """Muestra información general de un dataset."""

    print(f"\n--- {name.upper()} ---")
    print(f"Filas: {len(dataframe):,}")
    print(f"Columnas: {len(dataframe.columns):,}")

    print("\nTipos de datos:")
    print(dataframe.dtypes.to_string())

    missing = dataframe.isnull().sum()
    missing = missing[missing > 0]

    print("\nValores faltantes:")
    if missing.empty:
        print("No se encontraron valores faltantes.")
    else:
        print(missing.to_string())

    print(f"\nFilas duplicadas completas: {dataframe.duplicated().sum():,}")


def validate_ids(train, test, submission):
    """Comprueba duplicados y coincidencias de identificadores."""

    print("\n--- VALIDACIÓN DE IDENTIFICADORES ---")

    for name, dataframe in [
        ("train", train),
        ("test", test),
        ("sample_submission", submission),
    ]:
        duplicates = dataframe["id"].duplicated().sum()
        print(f"IDs duplicados en {name}: {duplicates:,}")

    overlap = set(train["id"]).intersection(set(test["id"]))

    print(f"IDs compartidos entre train y test: {len(overlap):,}")

    if train["id"].duplicated().any():
        raise ValueError("Existen IDs duplicados en train.")

    if test["id"].duplicated().any():
        raise ValueError("Existen IDs duplicados en test.")

    if submission["id"].duplicated().any():
        raise ValueError("Existen IDs duplicados en sample_submission.")

    if overlap:
        raise ValueError("Hay IDs compartidos entre train y test.")

    if set(submission["id"]) != set(test["id"]):
        raise ValueError(
            "Los IDs de sample_submission no coinciden con los de test."
        )


def inspect_target(train):
    """Analiza la distribución de la variable objetivo."""

    print("\n--- DISTRIBUCIÓN DE IS_FRAUD ---")

    print("\nFrecuencias:")
    print(train["is_fraud"].value_counts(dropna=False).to_string())

    print("\nPorcentajes:")
    print(
        (train["is_fraud"].value_counts(normalize=True, dropna=False) * 100)
        .to_string()
    )

    if train["is_fraud"].isnull().any():
        raise ValueError("La variable objetivo contiene valores faltantes.")

    if not set(train["is_fraud"].unique()).issubset({0, 1}):
        raise ValueError("is_fraud contiene valores diferentes de 0 y 1.")


def main():
    print("INICIANDO VALIDACIÓN DE DATOS")

    train, test, submission = load_datasets()

    print("\nArchivos cargados correctamente.")

    validate_columns(train, test, submission)

    inspect_dataset("train", train)
    inspect_dataset("test", test)
    inspect_dataset("sample_submission", submission)

    validate_ids(train, test, submission)

    inspect_target(train)

    print("\nVALIDACIÓN COMPLETADA CORRECTAMENTE.")


if __name__ == "__main__":
    main()
