

WITH source_data AS (
    SELECT
        hk_price_line_item, 
        symbol, -- Hash key cho price_line_item
        open_time,
        open_price,
        high_price,
        low_price,
        close_price,
        volume,
        close_time,
        quote_asset_volume,
        number_of_trades,
        taker_buy_base_asset_volume,
        taker_buy_quote_asset_volume,
        CURRENT_TIMESTAMP() AS sat_load_datetime
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}  -- Tham chiếu đến bảng staging price_line_item
)

SELECT
    hk_price_line_item,
    symbol,   
    open_time,
    open_price,
    high_price,
    low_price,
    close_price,
    volume,
    close_time,
    quote_asset_volume,
    number_of_trades,
    taker_buy_base_asset_volume,
    taker_buy_quote_asset_volume,             
    sat_load_datetime         
FROM source_data
