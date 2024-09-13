{{ config(materialized='incremental',is_auto_end_dating=true) }}
{%- set source_model = "hstg_tpch__account_position" -%}
{%- set src_pk = "DV_CUSTOMER_SEGMENT__LINK_HASHKEY" -%}
{%- set src_dfk = "DV_CUSTOMER_HASHKEY"       -%}
{%- set src_sfk = "DV_SEGMENT_HASHKEY"         -%}
{%- set src_start_date = "START_DATE" -%}
{%- set src_end_date = "END_DATE"     -%}

{%- set src_eff = "EFFECTIVE_FROM"    -%}
{%- set src_ldts = "DV_LOAD_DATE"    -%}
{%- set src_source = "DV_RECORD_SOURCE"  -%}

{{ dbtvault.eff_sat(src_pk=src_pk, src_dfk=src_dfk, src_sfk=src_sfk,
                    src_start_date=src_start_date, 
                    src_end_date=src_end_date,
                    src_eff=src_eff, src_ldts=src_ldts, 
                    src_source=src_source,
                    source_model=source_model) }}