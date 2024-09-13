select A.C_CUSTKEY
    ,C.C_PHONE
    ,CASE
        uniform(0, 1, random())=0
    WHEN 1 THEN 'Office'
    WHEN 0 THEN'Home'
    END 
    as "C_PHONE_TYPE"
from  
{{ source('TPCH', 'CUSTOMER') }}  A
INNER JOIN 
(
    select T.C_PHONE from {{ source('TPCH', 'CUSTOMER') }} T
    group by T.C_PHONE
    LIMIT 200000
) C
   ON 1=1
-- Where A.C_CUSTKEY in (62045)
LIMIT 200000