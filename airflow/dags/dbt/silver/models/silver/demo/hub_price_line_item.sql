WITH source_data AS (
    SELECT
        hk_price_line_item,  
        id as business_key_price_line_item
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}  
)

SELECT
    hk_price_line_item,   
    business_key_price_line_item,         
    CURRENT_TIMESTAMP() AS hub_load_datetime
FROM source_data
