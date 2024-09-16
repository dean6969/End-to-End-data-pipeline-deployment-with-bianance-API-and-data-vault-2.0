SELECT
    pli.hk_symbol,
    pli.hk_price_line_item,
    CURRENT_TIMESTAMP() AS link_load_datetime
FROM {{ source('STAGING_TABLE', 'STG_HASH_PRICE_LINE_ITEM_SYMBOL') }} pli