WITH source_data AS (
    SELECT
        hk_current_price,  -- hash key for current_price
        id as business_key_price
        CURRENT_TIMESTAMP() AS hub_load_datetime
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}  -- reflect to stg_hash_current_price_symbol
)

SELECT
    hk_current_price,   -- hash key for current_price
    business_key_price,  
    hub_load_datetime     -- business key for price
FROM source_data