WITH source_data AS (
    SELECT
        hk_current_price,  -- Hash key cho current_price
        price,
        CURRENT_TIMESTAMP() AS sat_load_datetime
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}  -- Tham chiếu đến bảng staging current_price
)

SELECT
    hk_current_price,   -- Hash key cho current_price
    price,              -- Giá trị thuộc tính giá hiện tại
    sat_load_datetime       -- Thời gian tải
FROM source_data