USE DATABASE binance_database_dev;

USE SCHEMA RAW;

CREATE TABLE IF NOT EXISTS landing_current_price (
    data VARIANT,
    load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS landing_price_line_item (
    data VARIANT,
    load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_symbol (
    id STRING,
    symbol STRING,
    status STRING,
    baseAsset STRING,
    quoteAsset STRING
);
