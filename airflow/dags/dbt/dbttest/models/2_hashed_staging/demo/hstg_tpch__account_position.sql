{%- set yaml_metadata -%}
source_model: rstg_tpch__orders
derived_columns:
  DV_RECORD_SOURCE: '!rstg_tpch__orders'
  DV_LOAD_DATE: to_timestamp('{{ var('load_date') }}')
  START_DATE: dateadd(day, -1,to_timestamp('{{ var('load_date') }}'))
  END_DATE: to_timestamp('9999-12-31 23:59:59.999999')
  EFFECTIVE_FROM: dateadd(day, -1,to_timestamp('{{ var('load_date') }}'))
  CUSTOMER_ID: C_CUSTKEY
  DV_TENANT_ID: '!default'
  DV_BKEY_CODE: '!default'
  DV_TASK_ID: '!123'
  DV_APPLIED_DATE: to_date('{{ var('applied_date') }}')
  DV_USER_ID: '!trantrongnghia1991@gmail.com'
  SEGMENT_ID: C_SEGMENT
  SATELLITE_NAME_1: '!RAW__SAT_FAKECUSTOMER'
  Fake_Address : '!{{ var('fake_address') }}'
hashed_columns: 
    DV_CUSTOMER_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_CUSTKEY
    DV_SEGMENT_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_SEGMENT
    DV_CUSTOMER_SEGMENT__LINK_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_CUSTKEY
    - C_SEGMENT
    DV_CUSTOMER_HASHDIFF:
      is_hashdiff: true
      columns:
        - CUSTOMER_ID
        - C_NAME
        - C_ADDRESS
        - C_CASH
    DV_CUSTOMER_SEGMENT_HASHDIFF:
        is_hashdiff: true
        columns:
          - C_SEGMENT
    DV_CUSTOMER_RECORD_HASHDIFF:
        is_hashdiff: true
        columns:
          - DV_LOAD_DATE
    DV_FAKECUSTOMER__HASHDIFF:
        is_hashdiff: true
        columns:
          - Fake_Address
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ dbtvault.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}