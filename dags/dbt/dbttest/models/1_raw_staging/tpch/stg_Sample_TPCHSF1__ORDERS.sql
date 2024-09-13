select
    O_ORDERKEY as "_KEY_ORDER",
    O_CUSTKEY  as "_KEY_CUSTOMER",
    O_TOTALPRICE as "Amount"
from {{ source('TPCH', 'ORDERS') }} 