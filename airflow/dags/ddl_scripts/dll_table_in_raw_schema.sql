USE DATABASE binance_database_dev;

CREATE TABLE IF NOT EXISTS raw_symbol_data (
    symbol VARCHAR(255),
    status VARCHAR(50),
    baseAsset VARCHAR(255),
    quoteAsset VARCHAR(255),
    record_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_price_line_item_data (
        symbol VARCHAR(255),
        open_time TIMESTAMP,
        open_price DECIMAL(18, 6),
        high_price DECIMAL(18, 6),
        low_price DECIMAL(18, 6),
        close_price DECIMAL(18, 6),
        volume DECIMAL(18, 6),
        close_time TIMESTAMP,
        quote_asset_volume DECIMAL(18, 6),
        number_of_trades INT,
        taker_buy_base_asset_volume DECIMAL(18, 6),
        taker_buy_quote_asset_volume DECIMAL(18, 6),
        record_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

USE DATABASE binance_database_dev;

CREATE TABLE IF NOT EXISTS raw_current_price_data (
    symbol VARCHAR(255),
    price DECIMAL(18, 6),
    timestamp TIMESTAMP,
    load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
