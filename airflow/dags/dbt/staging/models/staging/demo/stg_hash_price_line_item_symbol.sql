WITH price_line_item AS (
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_PRICE_LINE_ITEM') }}
),
symbol AS (
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_SYMBOL') }}
)
SELECT 
    -- Thêm hash key cho price_line_item và symbol sử dụng MD5
    MD5(pli.symbol) AS hk_symbol,  -- Hash key cho symbol bằng MD5
    MD5(CONCAT(pli.symbol, pli.open_time, pli.close_time)) AS hk_price_line_item,  -- Hash key cho price_line_item dựa trên nhiều cột
    
    -- Các cột từ price_line_item
    pli.id,
    pli.symbol,
    pli.open_time,
    pli.open_price,
    pli.high_price,
    pli.low_price,
    pli.close_price,
    pli.volume,
    pli.close_time,
    pli.quote_asset_volume,
    pli.number_of_trades,
    pli.taker_buy_base_asset_volume,
    pli.taker_buy_quote_asset_volume,
    pli.load_datetime,
    
    -- Các cột từ symbol
    s.id AS symbol_id,
    s.symbol AS symbol_symbol,
    s.status,
    s.baseAsset,
    s.quoteAsset
FROM price_line_item pli
LEFT JOIN symbol s
ON pli.symbol = s.symbol
