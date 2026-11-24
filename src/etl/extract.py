from pathlib import Path

import pandas as pd


# Directorio raíz del proyecto
PROJECT_ROOT = Path(__file__).resolve().parents[2]

# Directorio que contiene los archivos originales de Kaggle
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def extract_csv(file_name):
    """
    Lee un archivo CSV desde data/raw y devuelve un DataFrame.
    """
    file_path = RAW_DATA_DIR / file_name

    if not file_path.exists():
        raise FileNotFoundError(
            f"No se encontró el archivo: {file_path}"
        )

    return pd.read_csv(file_path)


def extract_all():
    """
    Extrae los tres archivos CSV de la competencia.
    """
    train = extract_csv("train.csv")
    test = extract_csv("test.csv")
    sample_submission = extract_csv("sample_submission.csv")

    return train, test, sample_submission


if __name__ == "__main__":
    train, test, sample_submission = extract_all()

    print("Extracción completada.\n")

    print(f"Train: {train.shape}")
    print(f"Test: {test.shape}")
    print(f"Sample submission: {sample_submission.shape}")
