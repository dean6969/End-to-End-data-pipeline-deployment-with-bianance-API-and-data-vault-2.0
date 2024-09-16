WITH source_data AS (
    SELECT
        hk_current_price, 
        CURRENT_TIMESTAMP() AS sat_load_datetime
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}  

SELECT
    hk_current_price,   
    price,              
    sat_load_datetime       
FROM source_data