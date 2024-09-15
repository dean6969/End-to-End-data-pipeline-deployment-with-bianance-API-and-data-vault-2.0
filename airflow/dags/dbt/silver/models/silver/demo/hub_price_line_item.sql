WITH source_data AS (
    SELECT
        hk_price_line_item,  -- Hash key cho price_line_item
        id as business_key_price_line_item
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}  -- Tham chiếu đến bảng staging price_line_item
)

SELECT
    hk_price_line_item,   -- Hash key cho price_line_item
    business_key_price_line_item,         -- Business key cho price_line_item
    CURRENT_TIMESTAMP() AS hub_load_datetime
FROM source_data
