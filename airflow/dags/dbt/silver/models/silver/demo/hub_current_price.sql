{{ config(
    materialized='incremental',
    unique_key='hk_current_price'
) }}

WITH source_data AS (
    SELECT
        hk_current_price,  -- Hash key cho current_price
        id as business_key_price
    FROM {{ source('STAGING_TABLE', 'STG_HASH_CURRENT_PRICE_SYMBOL') }}  -- Tham chiếu đến bảng staging current_price
)

SELECT
    hk_current_price,   -- Hash key cho current_price
    business_key_price,       -- Business key cho current_price
    CURRENT_TIMESTAMP() AS hub_load_datetime
FROM source_data