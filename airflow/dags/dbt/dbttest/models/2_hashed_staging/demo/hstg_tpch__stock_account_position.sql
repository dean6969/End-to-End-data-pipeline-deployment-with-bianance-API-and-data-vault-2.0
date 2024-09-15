{%- set yaml_metadata -%}
source_model: rstg_tpch__stock_account_position
derived_columns:
  DV_RECORD_SOURCE: '!rstg_tpch__stock_account_position'
  DV_LOAD_DATE: to_timestamp('{{ var('load_date') }}')
  DV_TENANT_ID: '!default'
  DV_BKEY_CODE: '!default'
  DV_TASK_ID: '!124'
  DV_APPLIED_DATE: to_timestamp('{{ var('load_date') }}')
  DV_USER_ID: '!trantrongnghia1991@gmail.com'
hashed_columns:
    DV_CUSTOMER_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_CUSTKEY
    DV_STOCK_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_STOCKKEY
    DV_ACCOUNT_POSITION__LINK_HASHKEY:
    - DV_TENANT_ID
    - DV_BKEY_CODE
    - C_CUSTKEY
    - C_STOCKKEY
    DV_HASHDIFF:
      is_hashdiff: true
      columns:
        - C_CUSTKEY
        - C_STOCKKEY
        - C_QUANTITY
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ dbtvault.stage(include_source_columns=true,
                  source_model= metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}