import subprocess
import zipfile
from pathlib import Path


# Identificador de la competencia
COMPETITION = "playground-series-s6e11"

# Directorios del proyecto
PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

# Archivos que esperamos encontrar
EXPECTED_FILES = [
    "train.csv",
    "test.csv",
    "sample_submission.csv",
]


def download_data():
    """
    Descarga los archivos de la competencia Kaggle
    y los extrae en data/raw/.
    """

    RAW_DATA_DIR.mkdir(parents=True, exist_ok=True)

    # Comprobar si los archivos ya existen
    existing_files = [
        file for file in EXPECTED_FILES
        if (RAW_DATA_DIR / file).exists()
    ]

    if len(existing_files) == len(EXPECTED_FILES):
        print("Los archivos de la competencia ya están descargados.")
        return

    # Descargar archivos mediante Kaggle API
    command = [
        "kaggle",
        "competitions",
        "download",
        "-c", COMPETITION,
        "-p", str(RAW_DATA_DIR),
    ]

    print(f"Descargando datos de Kaggle: {COMPETITION}")

    subprocess.run(command, check=True)

    # Localizar el archivo ZIP descargado
    zip_files = list(RAW_DATA_DIR.glob("*.zip"))

    if not zip_files:
        raise FileNotFoundError(
            "No se encontró el archivo ZIP descargado."
        )

    zip_path = zip_files[0]

    # Extraer archivos
    print(f"Extrayendo archivos de {zip_path.name}")

    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(RAW_DATA_DIR)

    # Verificar archivos esperados
    missing_files = [
        file for file in EXPECTED_FILES
        if not (RAW_DATA_DIR / file).exists()
    ]

    if missing_files:
        raise FileNotFoundError(
            f"No se encontraron los siguientes archivos: {missing_files}"
        )

    print("\nDescarga y extracción completadas.")

    for file in EXPECTED_FILES:
        file_path = RAW_DATA_DIR / file
        print(f"{file}: {file_path.stat().st_size:,} bytes")


if __name__ == "__main__":
    download_data()
