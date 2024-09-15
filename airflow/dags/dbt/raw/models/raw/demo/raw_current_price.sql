 
SELECT
    data:id::STRING AS id,
    data:price::FLOAT AS price,
    data:symbol::STRING AS symbol,
    data:timestamp::TIMESTAMP AS record_datetime,
    load_datetime
FROM {{ source('RAW_TABLE', 'LANDING_CURRENT_PRICE') }} 