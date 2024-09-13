SELECT 
    MD5(CONCAT_WS('||', 
    IFNULL(NULLIF(UPPER(TRIM(CAST(A.DV_CUSTOMER_HASHKEY AS VARCHAR))), ''), '^^'),
    IFNULL(NULLIF(UPPER(TRIM(CAST(A.DV_LOAD_DATE AS VARCHAR))), ''), '^^')
    )) as "_KEY_Account_Detail"
    ,to_char(A.DV_CUSTOMER_HASHKEY) as "_KEY_CUSTOMER"
    , to_date(A.DV_LOAD_DATE) as "_KEY_DATE"
    , A.C_CASH as "Amount"
FROM {{ ref('RAW__SAT_CUSTOMER') }} A
