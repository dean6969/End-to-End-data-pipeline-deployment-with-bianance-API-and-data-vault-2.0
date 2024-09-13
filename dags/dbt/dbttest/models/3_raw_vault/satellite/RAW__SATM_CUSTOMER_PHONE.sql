{%- set yaml_metadata -%}
source_model: "hstg_tpch__phonecustomer"
src_pk: "DV_CUSTOMER_HASHKEY"
src_cdk: 
  - C_PHONE
src_hashdiff: 
  source_column: "DV_CUSTOMERPHONE_HASHDIFF"
  alias: "HASHDIFF"
src_payload:
    - C_PHONE_TYPE
src_ldts: "DV_LOAD_DATE"
src_source: "DV_RECORD_SOURCE"
src_extra_columns:
    - DV_TENANT_ID
    - DV_TASK_ID
    - DV_APPLIED_DATE
    - DV_USER_ID
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ dbtvault.ma_sat(src_pk=metadata_dict["src_pk"],
                 src_cdk=metadata_dict['src_cdk'],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                src_ldts=metadata_dict["src_ldts"],
                src_source=metadata_dict["src_source"],
                source_model=metadata_dict["source_model"],   
                src_extra_columns=metadata_dict["src_extra_columns"]
                )
                }}