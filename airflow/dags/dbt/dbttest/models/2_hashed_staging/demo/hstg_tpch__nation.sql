{%- set yaml_metadata -%}
source_model: rstg_tpch__nation
derived_columns:
  DV_RECORD_SOURCE: '!rstg_tpch__nation'
  DV_LOAD_DATE: to_timestamp('{{ var('load_date') }}')
  DV_TENANT_ID: '!default'
  DV_BKEY_CODE: '!default'
  DV_TASK_ID: '!123'
  DV_APPLIED_DATE: to_timestamp('{{ var('load_date') }}')
  DV_USER_ID: '!trantrongnghia1991@gmail.com'
hashed_columns: 
    DV_NATION_HASHDIFF:
      is_hashdiff: true
      columns:
        - N_NAME
        - N_COMMENT
        - N_REGIONKEY
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ dbtvault.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}