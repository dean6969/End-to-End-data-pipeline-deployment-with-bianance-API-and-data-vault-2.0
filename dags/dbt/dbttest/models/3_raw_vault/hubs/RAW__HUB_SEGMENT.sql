{%- set source_model = "hstg_tpch__account_position" -%}
{%- set src_pk = "DV_SEGMENT_HASHKEY" -%}
{%- set src_nk = "SEGMENT_ID" -%}
{%- set src_ldts = "DV_LOAD_DATE" -%}
{%- set src_source = "DV_RECORD_SOURCE" -%}
{%- set src_extra_columns = ["DV_TENANT_ID", "DV_BKEY_CODE","DV_TASK_ID","DV_APPLIED_DATE","DV_USER_ID"] -%}

{{ dbtvault.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                src_source=src_source, source_model=source_model,src_extra_columns=src_extra_columns) }}