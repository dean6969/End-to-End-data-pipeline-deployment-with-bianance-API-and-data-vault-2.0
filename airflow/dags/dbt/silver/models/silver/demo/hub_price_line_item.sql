WITH source_data AS (
    SELECT
        hk_price_line_item,  -- Hash key for price_line_item
        id as business_key_price_line_item
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}  -- reflect to stg_hash_price_line_item_symbol
)

SELECT
    hk_price_line_item,   
    business_key_price_line_item,         -
    CURRENT_TIMESTAMP() AS hub_load_datetime
FROM source_data
