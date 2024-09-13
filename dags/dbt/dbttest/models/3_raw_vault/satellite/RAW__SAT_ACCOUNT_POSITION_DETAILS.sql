{%- set yaml_metadata -%}
source_model: "hstg_tpch__stock_account_position"
src_pk: "DV_ACCOUNT_POSITION__LINK_HASHKEY"
src_hashdiff: 
  source_column: "DV_HASHDIFF"
  alias: "HASHDIFF"
src_payload:
    - C_QUANTITY
src_ldts: "DV_LOAD_DATE"
src_source: "DV_RECORD_SOURCE"
src_extra_columns:
    - DV_TENANT_ID
    - DV_TASK_ID
    - DV_APPLIED_DATE
    - DV_USER_ID
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ dbtvault.sat(src_pk=metadata_dict["src_pk"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                src_ldts=metadata_dict["src_ldts"],
                src_source=metadata_dict["src_source"],
                source_model=metadata_dict["source_model"],   
                src_extra_columns=metadata_dict["src_extra_columns"]
                )
                }}