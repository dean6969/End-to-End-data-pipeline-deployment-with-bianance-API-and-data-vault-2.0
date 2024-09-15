select 
    to_char(A.DV_STOCK_HASHKEY) as "_KEY_STOCK"
    , A.C_STOCKKEY as "Stock Id"
from  {{ ref('RAW__HUB_STOCK') }} A
