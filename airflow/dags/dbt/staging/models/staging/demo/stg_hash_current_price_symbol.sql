WITH current_price AS (
    -- data source current_price
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_CURRENT_PRICE') }}
),
symbol AS (
    -- data source symbol
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_SYMBOL') }}
)

SELECT
    MD5(cp.symbol) AS hk_symbol,  -- create hash key for symbol
    MD5(CONCAT(cp.symbol, cp.record_datetime)) AS hk_current_price,  -- create hash key for current_price
    cp.id,
    cp.price,
    cp.symbol,
    cp.record_datetime,
    cp.load_datetime,
    s.id AS symbol_id,
    s.symbol AS symbol_symbol,
    s.status,
    s.baseAsset,
    s.quoteAsset
FROM current_price cp
LEFT JOIN symbol s
ON cp.symbol = s.symbol
