WITH current_price AS (
    -- Tham chiếu đến mô hình raw_current_price
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_CURRENT_PRICE') }}
),
symbol AS (
    -- Dữ liệu từ bảng raw_symbol
    SELECT *
    FROM {{ source('RAW_TABLE', 'RAW_SYMBOL') }}
)

SELECT
    MD5(cp.symbol) AS hk_symbol,  -- Tạo hash key cho symbol bằng MD5
    MD5(CONCAT(cp.symbol, cp.record_datetime)) AS hk_current_price,  -- Tạo hash key cho current_price bằng cách kết hợp symbol và record_datetime
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
