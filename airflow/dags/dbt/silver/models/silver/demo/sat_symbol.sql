WITH combined_symbol_attributes AS (
    SELECT 
        hk_symbol, 
        status, 
        baseAsset, 
        quoteAsset,
        load_datetime 
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}
    
    UNION
    
    SELECT 
        hk_symbol, 
        status, 
        baseAsset, 
        quoteAsset,
        load_datetime 
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}
)

SELECT
    hk_symbol,
    status,
    baseAsset,
    quoteAsset,
    load_datetime AS sat_load_datetime
FROM combined_symbol_attributes
