import pandas as pd


TARGET_COLUMN = "is_fraud"

EXPECTED_COLUMNS = [
    "id",
    "amount_usd",
    "hours_since_last_txn",
    "txn_count_last_24h",
    "distance_from_home_km",
    "card_age_months",
    "customer_age",
    "account_balance_usd",
    "cvv_retry_count",
    "velocity_score",
    "time_of_day_hour",
    "day_of_week",
    "merchant_risk_score",
    "prior_disputes",
    "merchant_category",
    "card_type",
    "auth_method",
    "channel",
    "device_type",
    "is_foreign_transaction",
    "is_new_merchant",
    "used_vpn",
    "ip_country_mismatch",
    "billing_shipping_mismatch",
    "is_ai_generated_scam_attempt",
]


def validate_columns(df, expected_columns, dataset_name):
    """
    Comprueba que un DataFrame tenga exactamente las columnas esperadas.
    """
    if list(df.columns) != expected_columns:
        raise ValueError(
            f"Las columnas de {dataset_name} no coinciden "
            "con las esperadas."
        )


def transform_data(train, test, sample_submission):
    """
    Valida y prepara los DataFrames para su carga en PostgreSQL.
    """

    # 1. Validar estructura de los archivos
    validate_columns(
        train,
        EXPECTED_COLUMNS + [TARGET_COLUMN],
        "train",
    )

    validate_columns(
        test,
        EXPECTED_COLUMNS,
        "test",
    )

    validate_columns(
        sample_submission,
        ["id", TARGET_COLUMN],
        "sample_submission",
    )

    # 2. Validar valores del target
    if train[TARGET_COLUMN].isna().any():
        raise ValueError("El target contiene valores nulos.")

    if not train[TARGET_COLUMN].isin([0, 1]).all():
        raise ValueError("El target contiene valores distintos de 0 y 1.")

    # 3. Convertir target a entero
    train = train.copy()
    train[TARGET_COLUMN] = train[TARGET_COLUMN].astype("int16")

    # 4. Validar identificadores
    for df, name in [
        (train, "train"),
        (test, "test"),
        (sample_submission, "sample_submission"),
    ]:
        if df["id"].isna().any():
            raise ValueError(f"El campo id contiene nulos en {name}.")

        if df["id"].duplicated().any():
            raise ValueError(f"Hay identificadores duplicados en {name}.")

    # 5. Comprobar que train y test no compartan identificadores
    if train["id"].isin(test["id"]).any():
        raise ValueError("Hay identificadores compartidos entre train y test.")

    # 6. Validar que sample_submission corresponda a test
    if not sample_submission["id"].equals(test["id"]):
        raise ValueError(
            "Los identificadores de sample_submission "
            "no coinciden con los de test o están en distinto orden."
        )

    # 7. Validar probabilidades de sample_submission
    probabilities = sample_submission[TARGET_COLUMN]

    if probabilities.isna().any():
        raise ValueError("sample_submission contiene probabilidades nulas.")

    if not probabilities.between(0, 1).all():
        raise ValueError(
            "Las probabilidades deben estar entre 0 y 1."
        )

    print("Validaciones y transformaciones completadas.")

    return train, test, sample_submission
