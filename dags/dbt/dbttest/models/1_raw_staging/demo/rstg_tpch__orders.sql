select A.C_CUSTKEY
    ,A.C_NAME
    ,CASE
        uniform(0, 1, random())=0
    WHEN 1 THEN 'Ha Noi'
    WHEN 0 THEN'Ho Chi Minh'
    END 
as "C_ADDRESS"
,CASE
        uniform(0, 1, random())=0
    WHEN 1 THEN 'VIP'
    WHEN 0 THEN'NORMAL'
    END 
as "C_SEGMENT"
    ,A.C_NATIONKEY
    ,SUM(B.O_TOTALPRICE) -  uniform(0, 1, random()) as "C_CASH"
    
from  
{{ source('TPCH', 'CUSTOMER') }}  A
INNER JOIN {{ source('TPCH', 'ORDERS') }} B
ON A.C_CUSTKEY = B.O_CUSTKEY
-- Where B.O_ORDERDATE = '1992-01-01'
-- and A.C_CUSTKEY in (62045)
GROUP BY 1,2,3,4,5
-- LIMIT 1