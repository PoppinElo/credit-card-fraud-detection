-- =====================================================
-- EDA: EXPLORATORY DATA ANALYSIS
-- Proyecto: Credit Card Fraud Detection
-- Dataset: Kaggle Playground Series S6E11
-- =====================================================


-- 1. DISTRIBUCION ABSOLUTA DEL TARGET
-- Cantidad de transacciones fraudulentas y legitimas.

SELECT
    is_fraud,
    COUNT(*) AS total_transactions
FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;


-- 2. DISTRIBUCION PORCENTUAL DEL TARGET
-- Proporcion de cada clase respecto al total.

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;


-- 3. INDICADORES GENERALES DEL DATASET
-- Resumen general de las transacciones.

SELECT
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    COUNT(*) - SUM(is_fraud) AS legitimate_transactions,
    ROUND(AVG(is_fraud) * 100, 4) AS fraud_rate
FROM raw.train;

-- 4. ANALISIS DE MONTO DE TRANSACCIONES
-- Comparacion entre transacciones fraudulentas y legitimas.

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount_usd)::numeric, 2) AS mean_amount,
    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY amount_usd)::numeric, 2
    ) AS q1_amount,
    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY amount_usd)::numeric, 2
    ) AS median_amount,
    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY amount_usd)::numeric, 2
    ) AS q3_amount,
    ROUND(MIN(amount_usd)::numeric, 2) AS min_amount,
    ROUND(MAX(amount_usd)::numeric, 2) AS max_amount
FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;

-- 5. TASA DE FRAUDE SEGUN RANGO DE MONTO

SELECT
    CASE
        WHEN amount_usd < 25 THEN '01. Menos de 25'
        WHEN amount_usd < 50 THEN '02. 25 - 49.99'
        WHEN amount_usd < 100 THEN '03. 50 - 99.99'
        WHEN amount_usd < 250 THEN '04. 100 - 249.99'
        WHEN amount_usd < 500 THEN '05. 250 - 499.99'
        ELSE '06. 500 o mas'
    END AS amount_range,

    COUNT(*) AS total_transactions,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM raw.train

GROUP BY 1

ORDER BY 1;

-- 6. ANALISIS DEL SALDO DE CUENTA
-- Comparacion entre transacciones fraudulentas y legitimas.

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,

    ROUND(AVG(account_balance_usd)::numeric, 2) AS mean_balance,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY account_balance_usd)::numeric, 2
    ) AS q1_balance,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY account_balance_usd)::numeric, 2
    ) AS median_balance,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY account_balance_usd)::numeric, 2
    ) AS q3_balance,

    ROUND(MIN(account_balance_usd)::numeric, 2) AS min_balance,

    ROUND(MAX(account_balance_usd)::numeric, 2) AS max_balance

FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;

-- 7. TASA DE FRAUDE SEGUN QUINTILES DEL SALDO
-- Cada grupo contiene aproximadamente el 20% de los registros.

WITH balance_groups AS (

    SELECT
        account_balance_usd,
        is_fraud,
        NTILE(5) OVER (
            ORDER BY account_balance_usd
        ) AS balance_quintile

    FROM raw.train

)

SELECT
    balance_quintile,

    COUNT(*) AS total_transactions,

    MIN(account_balance_usd)::numeric(12,2) AS min_balance,

    MAX(account_balance_usd)::numeric(12,2) AS max_balance,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM balance_groups

GROUP BY balance_quintile

ORDER BY balance_quintile;

-- 8. ESTADISTICAS DESCRIPTIVAS DE DISTANCIA AL DOMICILIO

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,

    ROUND(AVG(distance_from_home_km)::numeric, 2)
        AS mean_distance,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY distance_from_home_km)::numeric,
        2
    ) AS q1_distance,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY distance_from_home_km)::numeric,
        2
    ) AS median_distance,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY distance_from_home_km)::numeric,
        2
    ) AS q3_distance,

    ROUND(MIN(distance_from_home_km)::numeric, 2)
        AS min_distance,

    ROUND(MAX(distance_from_home_km)::numeric, 2)
        AS max_distance

FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;

-- 9. TASA DE FRAUDE SEGUN QUINTILES DE DISTANCIA

WITH distance_groups AS (

    SELECT
        distance_from_home_km,
        is_fraud,

        NTILE(5) OVER (
            ORDER BY distance_from_home_km
        ) AS distance_quintile

    FROM raw.train

)

SELECT
    distance_quintile,

    COUNT(*) AS total_transactions,

    MIN(distance_from_home_km)::numeric(12,2)
        AS min_distance,

    MAX(distance_from_home_km)::numeric(12,2)
        AS max_distance,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM distance_groups

GROUP BY distance_quintile

ORDER BY distance_quintile;

-- 10. ESTADISTICAS DESCRIPTIVAS DEL TIEMPO
-- DESDE LA ULTIMA TRANSACCION

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,

    ROUND(AVG(hours_since_last_txn)::numeric, 2)
        AS mean_hours,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY hours_since_last_txn)::numeric,
        2
    ) AS q1_hours,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY hours_since_last_txn)::numeric,
        2
    ) AS median_hours,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY hours_since_last_txn)::numeric,
        2
    ) AS q3_hours,

    ROUND(MIN(hours_since_last_txn)::numeric, 2)
        AS min_hours,

    ROUND(MAX(hours_since_last_txn)::numeric, 2)
        AS max_hours

FROM raw.train
GROUP BY is_fraud
ORDER BY is_fraud;

-- 11. TASA DE FRAUDE SEGUN QUINTILES DE TIEMPO
-- DESDE LA ULTIMA TRANSACCION

WITH time_groups AS (

    SELECT
        hours_since_last_txn,
        is_fraud,

        NTILE(5) OVER (
            ORDER BY hours_since_last_txn
        ) AS time_quintile

    FROM raw.train

)

SELECT
    time_quintile,

    COUNT(*) AS total_transactions,

    MIN(hours_since_last_txn)::numeric(12,2)
        AS min_hours,

    MAX(hours_since_last_txn)::numeric(12,2)
        AS max_hours,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM time_groups

GROUP BY time_quintile

ORDER BY time_quintile;

-- 12. ESTADISTICAS DESCRIPTIVAS DE TRANSACCIONES
-- EN LAS ULTIMAS 24 HORAS

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,

    ROUND(AVG(txn_count_last_24h)::numeric, 2)
        AS mean_txn_count,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY txn_count_last_24h)::numeric,
        2
    ) AS q1_txn_count,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY txn_count_last_24h)::numeric,
        2
    ) AS median_txn_count,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY txn_count_last_24h)::numeric,
        2
    ) AS q3_txn_count,

    MIN(txn_count_last_24h) AS min_txn_count,

    MAX(txn_count_last_24h) AS max_txn_count

FROM raw.train

GROUP BY is_fraud

ORDER BY is_fraud;

-- 13. TASA DE FRAUDE SEGUN CANTIDAD DE TRANSACCIONES
-- EN LAS ULTIMAS 24 HORAS

SELECT
    txn_count_last_24h,

    COUNT(*) AS total_transactions,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM raw.train

GROUP BY txn_count_last_24h

ORDER BY txn_count_last_24h;

-- 14. ESTADISTICAS DESCRIPTIVAS DE VELOCITY SCORE

SELECT
    is_fraud,
    COUNT(*) AS total_transactions,

    ROUND(AVG(velocity_score)::numeric, 2)
        AS mean_velocity,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY velocity_score)::numeric,
        2
    ) AS q1_velocity,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY velocity_score)::numeric,
        2
    ) AS median_velocity,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY velocity_score)::numeric,
        2
    ) AS q3_velocity,

    ROUND(MIN(velocity_score)::numeric, 2)
        AS min_velocity,

    ROUND(MAX(velocity_score)::numeric, 2)
        AS max_velocity

FROM raw.train

GROUP BY is_fraud

ORDER BY is_fraud;

-- 15. TASA DE FRAUDE SEGUN QUINTILES DE VELOCITY SCORE

WITH velocity_groups AS (

    SELECT
        velocity_score,
        is_fraud,

        NTILE(5) OVER (
            ORDER BY velocity_score
        ) AS velocity_quintile

    FROM raw.train

)

SELECT
    velocity_quintile,

    COUNT(*) AS total_transactions,

    MIN(velocity_score)::numeric(12,2)
        AS min_velocity,

    MAX(velocity_score)::numeric(12,2)
        AS max_velocity,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM velocity_groups

GROUP BY velocity_quintile

ORDER BY velocity_quintile;

-- 16. TASA DE FRAUDE SEGUN CVV RETRY COUNT

SELECT
    cvv_retry_count,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM raw.train

GROUP BY cvv_retry_count

ORDER BY cvv_retry_count;

-- 17. TASA DE FRAUDE SEGUN ANTIGUEDAD DE LA TARJETA

WITH card_age_groups AS (

    SELECT
        card_age_months,
        is_fraud,

        NTILE(5) OVER (
            ORDER BY card_age_months
        ) AS age_quintile

    FROM raw.train

)

SELECT
    age_quintile,
    COUNT(*) AS total_transactions,
    MIN(card_age_months) AS min_card_age_months,
    MAX(card_age_months) AS max_card_age_months,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM card_age_groups

GROUP BY age_quintile

ORDER BY age_quintile;

-- 18. TASA DE FRAUDE SEGUN EDAD DEL CLIENTE

WITH customer_age_groups AS (

    SELECT
        customer_age,
        is_fraud,

        NTILE(5) OVER (
            ORDER BY customer_age
        ) AS age_quintile

    FROM raw.train

)

SELECT
    age_quintile,
    COUNT(*) AS total_transactions,
    MIN(customer_age) AS min_customer_age,
    MAX(customer_age) AS max_customer_age,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM customer_age_groups

GROUP BY age_quintile

ORDER BY age_quintile;

-- 19. TASA DE FRAUDE SEGUN TRANSACCION EXTRANJERA

SELECT
    is_foreign_transaction,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage

FROM raw.train

GROUP BY is_foreign_transaction

ORDER BY is_foreign_transaction;

-- 20. TASA DE FRAUDE SEGUN SI EL COMERCIO ES NUEVO

SELECT
    is_new_merchant,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY is_new_merchant

ORDER BY is_new_merchant;

-- 21. TASA DE FRAUDE SEGUN USO DE VPN

SELECT
    used_vpn,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY used_vpn

ORDER BY used_vpn;

-- 22. TASA DE FRAUDE SEGUN DISCREPANCIA DE PAIS IP

SELECT
    ip_country_mismatch,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY ip_country_mismatch

ORDER BY ip_country_mismatch;

-- 23. TASA DE FRAUDE SEGUN DISCREPANCIA DE DIRECCIONES

SELECT
    billing_shipping_mismatch,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY billing_shipping_mismatch

ORDER BY billing_shipping_mismatch;

-- 24. TASA DE FRAUDE SEGUN INTENTO DE ESTAFA GENERADO
--     MEDIANTE IA

SELECT
    is_ai_generated_scam_attempt,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY is_ai_generated_scam_attempt

ORDER BY is_ai_generated_scam_attempt;

-- 25. TASA DE FRAUDE SEGUN CATEGORIA DEL COMERCIANTE

SELECT
    merchant_category,

    COUNT(*) AS total_transactions,

    SUM(is_fraud) AS fraudulent_transactions,

    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions

FROM raw.train

GROUP BY merchant_category

ORDER BY fraud_rate_percentage DESC;

-- 26. TASA DE FRAUDE SEGUN TIPO DE TARJETA

SELECT
    card_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY card_type
ORDER BY fraud_rate_percentage DESC;

-- 27. TASA DE FRAUDE SEGUN METODO DE AUTENTICACION

SELECT
    auth_method,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY auth_method
ORDER BY fraud_rate_percentage DESC;

-- 28. TASA DE FRAUDE SEGUN CANAL DE TRANSACCION

SELECT
    channel,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY channel
ORDER BY fraud_rate_percentage DESC;

-- 29. TASA DE FRAUDE SEGUN TIPO DE DISPOSITIVO

SELECT
    device_type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY device_type
ORDER BY fraud_rate_percentage DESC;

-- 30. TASA DE FRAUDE SEGUN HORA DEL DIA

SELECT
    time_of_day_hour,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY time_of_day_hour
ORDER BY time_of_day_hour;

-- 31. TASA DE FRAUDE SEGUN DIA DE LA SEMANA

SELECT
    day_of_week,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(AVG(is_fraud) * 100, 2) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY day_of_week
ORDER BY day_of_week;

-- 32. INTERACCION ENTRE TRANSACCIONES EXTRANJERAS
--     Y DISCREPANCIA ENTRE PAIS DE IP

SELECT
    is_foreign_transaction,
    ip_country_mismatch,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY
    is_foreign_transaction,
    ip_country_mismatch
ORDER BY
    is_foreign_transaction,
    ip_country_mismatch;
    
-- 33. INTERACCION ENTRE USO DE VPN Y DISCREPANCIA IP

SELECT
    used_vpn,
    ip_country_mismatch,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraudulent_transactions,
    ROUND(
        AVG(is_fraud) * 100,
        2
    ) AS fraud_rate_percentage,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_transactions
FROM raw.train
GROUP BY
    used_vpn,
    ip_country_mismatch
ORDER BY
    used_vpn,
    ip_country_mismatch;
