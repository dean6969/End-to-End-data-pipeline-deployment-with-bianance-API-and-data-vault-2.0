config(
    materialized='incremental',
    unique_key='hk_symbol'
)

WITH combined_symbol_data AS (
    SELECT 
        hk_symbol 
        ,symbol_id AS business_key_symbol 
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}
    UNION
    
    SELECT 
        hk_symbol
        ,symbol_id AS business_key_symbol  
    FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }}
)

SELECT
    hk_symbol
    ,business_key_symbol
    ,CURRENT_TIMESTAMP() AS hub_load_datetime
FROM combined_symbol_data
