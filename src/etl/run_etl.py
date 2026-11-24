from src.etl.extract import extract_all
from src.etl.transform import transform_data
from src.etl.load import load_data


def run_etl():

    print("=" * 50)
    print("INICIANDO ETL PIPELINE")
    print("=" * 50)

    # 1. EXTRACT
    print("\n[1/3] EXTRACT")

    train, test, sample_submission = extract_all()

    print(f"Train: {train.shape}")
    print(f"Test: {test.shape}")
    print(f"Sample submission: {sample_submission.shape}")

    # 2. TRANSFORM
    print("\n[2/3] TRANSFORM")

    train, test, sample_submission = transform_data(
        train,
        test,
        sample_submission,
    )

    # 3. LOAD
    print("\n[3/3] LOAD")

    load_data(
        train,
        test,
        sample_submission,
    )

    print("\n" + "=" * 50)
    print("ETL PIPELINE FINALIZADO CORRECTAMENTE")
    print("=" * 50)


if __name__ == "__main__":
    run_etl()
