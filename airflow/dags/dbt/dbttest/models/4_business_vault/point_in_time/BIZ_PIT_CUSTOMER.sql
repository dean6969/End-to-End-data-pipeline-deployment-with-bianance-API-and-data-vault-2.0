{{ config(materialized='pit_incremental') }}
{%- set yaml_metadata -%}
source_model: RAW__HUB_CUSTOMER
src_pk: DV_CUSTOMER_HASHKEY
as_of_dates_table: AS_OF_DATE
satellites: 
  RAW__SAT_CUSTOMER:
    pk:
      PK: DV_CUSTOMER_HASHKEY
    ldts:
      LDTS: DV_LOAD_DATE
  RAW__SAT_CUSTOMER_SEGMENT:
    pk:
      PK: DV_CUSTOMER_HASHKEY
    ldts:
      LDTS: DV_LOAD_DATE
stage_tables:
  hstg_tpch__account_position: DV_LOAD_DATE
src_ldts: DV_LOAD_DATE
{%- endset -%}


{% set metadata_dict = fromyaml(yaml_metadata) %}


{{ dbtvault.pit(source_model=metadata_dict['source_model'], 
                src_pk=metadata_dict['src_pk'],
                as_of_dates_table=metadata_dict['as_of_dates_table'],
                satellites=metadata_dict['satellites'],
                stage_tables_ldts=metadata_dict['stage_tables'],
                src_ldts=metadata_dict['src_ldts']) }}