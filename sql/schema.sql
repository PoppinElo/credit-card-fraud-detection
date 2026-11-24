-- ============================================================
-- Database: credit_fraud
-- Purpose: Initial database structure for Kaggle S6E11
-- ============================================================


-- 1. Create schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;


-- 2. Training dataset
CREATE TABLE IF NOT EXISTS raw.train (
    id BIGINT PRIMARY KEY,

    amount_usd DOUBLE PRECISION,
    hours_since_last_txn DOUBLE PRECISION,
    txn_count_last_24h INTEGER,
    distance_from_home_km DOUBLE PRECISION,
    card_age_months INTEGER,
    customer_age INTEGER,
    account_balance_usd DOUBLE PRECISION,
    cvv_retry_count INTEGER,
    velocity_score DOUBLE PRECISION,
    time_of_day_hour INTEGER,
    day_of_week INTEGER,
    merchant_risk_score DOUBLE PRECISION,
    prior_disputes INTEGER,

    merchant_category TEXT,
    card_type TEXT,
    auth_method TEXT,
    channel TEXT,
    device_type TEXT,

    is_foreign_transaction BOOLEAN,
    is_new_merchant BOOLEAN,
    used_vpn BOOLEAN,
    ip_country_mismatch BOOLEAN,
    billing_shipping_mismatch BOOLEAN,
    is_ai_generated_scam_attempt BOOLEAN,

    is_fraud SMALLINT NOT NULL CHECK (is_fraud IN (0, 1))
);


-- 3. Test dataset
CREATE TABLE IF NOT EXISTS raw.test (
    id BIGINT PRIMARY KEY,

    amount_usd DOUBLE PRECISION,
    hours_since_last_txn DOUBLE PRECISION,
    txn_count_last_24h INTEGER,
    distance_from_home_km DOUBLE PRECISION,
    card_age_months INTEGER,
    customer_age INTEGER,
    account_balance_usd DOUBLE PRECISION,
    cvv_retry_count INTEGER,
    velocity_score DOUBLE PRECISION,
    time_of_day_hour INTEGER,
    day_of_week INTEGER,
    merchant_risk_score DOUBLE PRECISION,
    prior_disputes INTEGER,

    merchant_category TEXT,
    card_type TEXT,
    auth_method TEXT,
    channel TEXT,
    device_type TEXT,

    is_foreign_transaction BOOLEAN,
    is_new_merchant BOOLEAN,
    used_vpn BOOLEAN,
    ip_country_mismatch BOOLEAN,
    billing_shipping_mismatch BOOLEAN,
    is_ai_generated_scam_attempt BOOLEAN
);


-- 4. Sample submission dataset
CREATE TABLE IF NOT EXISTS raw.sample_submission (
    id BIGINT PRIMARY KEY REFERENCES raw.test(id),
    is_fraud DOUBLE PRECISION NOT NULL
        CHECK (is_fraud >= 0 AND is_fraud <= 1)
);
