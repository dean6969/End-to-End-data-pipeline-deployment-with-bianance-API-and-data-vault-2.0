WITH
Temp1
as
(
select 
    A.O_CUSTKEY as "C_CUSTKEY"
    ,B.L_PARTKEY as "C_STOCKKEY"
    ,SUM(B.L_QUANTITY ) - uniform(-30000, 30000, random()) as "C_QUANTITY"
from  
{{ source('TPCH', 'ORDERS') }} A
INNER JOIN {{ source('TPCH', 'LINEITEM') }} B
ON A.O_ORDERKEY = B.L_ORDERKEY
-- Where A.O_ORDERDATE = '1992-01-01'
-- and A.O_CUSTKEY in (19397,1)
GROUP BY 1,2
)
select 
    "C_CUSTKEY"
    ,"C_STOCKKEY"
    ,iff("C_QUANTITY" < 0  , 0 , "C_QUANTITY") as "C_QUANTITY"
from Temp1