select
    C_CUSTKEY as "_KEY_CUSTOMER",
    C_NAME as "Customer"
    
from {{ source('TPCH', 'CUSTOMER') }}