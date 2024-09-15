{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: hstg_tpch__account_position
src_pk: DV_CUSTOMER_HASHKEY
src_satellite:
  RAW__SAT_FAKECUSTOMER:
    sat_name:
      SATELLITE_NAME: SATELLITE_NAME_1
    hashdiff:                
      HASHDIFF: DV_FAKECUSTOMER__HASHDIFF
src_ldts: DV_LOAD_DATE
src_source: DV_RECORD_SOURCE
src_extra_columns:
    DV_APPLIED_DATE
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict["source_model"] %}
{% set src_pk = metadata_dict["src_pk"] %}
{% set src_satellite = metadata_dict["src_satellite"] %}
{% set src_ldts = metadata_dict["src_ldts"] %}
{% set src_source = metadata_dict["src_source"] %}

{{ dbtvault.xts(src_pk=src_pk, src_satellite=src_satellite, src_ldts=src_ldts,
                src_source=src_source, source_model=source_model,
                src_extra_columns=metadata_dict["src_extra_columns"]
                ) }}