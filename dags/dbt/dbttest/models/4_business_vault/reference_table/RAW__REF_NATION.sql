{{
    config(
        unique_key='N_NATIONKEY'
    )
}}
select
*
from
{{ ref('rstg_tpch__nation') }}