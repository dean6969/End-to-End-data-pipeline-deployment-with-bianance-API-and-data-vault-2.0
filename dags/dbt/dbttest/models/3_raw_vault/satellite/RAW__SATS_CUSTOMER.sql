{{ config(materialized='incremental') }}
WITH source_data AS (
    SELECT 
        a."DV_CUSTOMER_HASHKEY"
        , a."DV_LOAD_DATE"
        , a."DV_TENANT_ID"
        , a."DV_RECORD_SOURCE"
        , 'I' as "DV_STATUS"
    FROM {{ ref('hstg_tpch__account_position') }} AS a
    WHERE a."DV_CUSTOMER_HASHKEY" IS NOT NULL
)
{%- if is_incremental() %}
,latest_records AS (
    SELECT 
        a."DV_CUSTOMER_HASHKEY"
        ,a."DV_STATUS"
        ,a."DV_TENANT_ID"
        ,a."DV_LOAD_DATE"
        ,a."DV_RECORD_SOURCE"
    FROM (
        SELECT 
            current_records."DV_CUSTOMER_HASHKEY"
            ,current_records."DV_STATUS"
            ,current_records."DV_TENANT_ID"
            ,current_records."DV_LOAD_DATE"
            ,current_records."DV_RECORD_SOURCE"
            ,RANK() OVER (
               PARTITION BY current_records."DV_CUSTOMER_HASHKEY"
               ORDER BY current_records."DV_LOAD_DATE" DESC
            ) AS rank
        FROM {{ this }} AS current_records
    ) AS a
    WHERE a.rank = 1
),Irecords AS (
    SELECT DISTINCT 
        a."DV_CUSTOMER_HASHKEY"
        , 'I' as "DV_STATUS"
        , a."DV_TENANT_ID"
        , a."DV_LOAD_DATE"
        , a."DV_RECORD_SOURCE"
    FROM source_data AS a
    Where NOT EXISTS
    (
        select 1
        from latest_records b
        where a."DV_CUSTOMER_HASHKEY" = b."DV_CUSTOMER_HASHKEY"
            AND b."DV_STATUS" <> 'D'
    )
    
),Drecords AS (
    SELECT DISTINCT 
        a."DV_CUSTOMER_HASHKEY"
        , 'D' as "DV_STATUS"
        , a."DV_TENANT_ID"
        , to_timestamp('{{ var('load_date') }}') as "DV_LOAD_DATE"
        , a."DV_RECORD_SOURCE"
    FROM latest_records AS a
        left join source_data AS b
            ON a.DV_CUSTOMER_HASHKEY = b.DV_CUSTOMER_HASHKEY
    Where NOT EXISTS
    (
        select 1
        from  source_data AS b
        where a."DV_CUSTOMER_HASHKEY" = b."DV_CUSTOMER_HASHKEY"
    )
    AND a."DV_RECORD_SOURCE" <> 'DBTVAULT_SYSTEM'   
    AND a."DV_STATUS" <> 'D'
),records_to_incremental AS (
select * from Irecords
UNION ALL
select * from Drecords
)
select *
from records_to_incremental
{% else %}
SELECT *
FROM source_data
{%- endif %}
