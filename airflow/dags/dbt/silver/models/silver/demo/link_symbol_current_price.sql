SELECT
    cp.hk_symbol,
    cp.hk_current_price,
    CURRENT_TIMESTAMP() AS link_load_datetime
FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }} cp