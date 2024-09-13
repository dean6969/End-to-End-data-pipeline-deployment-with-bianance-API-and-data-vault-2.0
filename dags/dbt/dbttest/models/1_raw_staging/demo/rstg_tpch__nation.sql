select
    *
from {{ source('TPCH', 'NATION') }} 