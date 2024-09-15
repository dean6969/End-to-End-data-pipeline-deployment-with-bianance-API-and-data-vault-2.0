With latest_records AS (
    SELECT a.*
    FROM (
        SELECT current_records.*,
            RANK() OVER (
               PARTITION BY current_records."DV_CUSTOMER_HASHKEY"
               ORDER BY current_records."DV_LOAD_DATE" DESC
            ) AS rank
        FROM {{ ref('RAW__SAT_CUSTOMER') }} AS current_records
    ) AS a
    WHERE a.rank = 1
)
select 
    to_char(A.DV_CUSTOMER_HASHKEY) as "_KEY_CUSTOMER"
    , B.C_NAME as "Customer Name"
    , B.C_ADDRESS as "Customer Address"
from  {{ ref('RAW__HUB_CUSTOMER') }} A
LEFT JOIN latest_records B 
    ON A.DV_CUSTOMER_HASHKEY = B.DV_CUSTOMER_HASHKEY