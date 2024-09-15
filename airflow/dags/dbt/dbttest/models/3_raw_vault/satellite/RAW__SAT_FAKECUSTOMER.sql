{%- set yaml_metadata -%}
source_model: "hstg_tpch__account_position"
src_pk: "DV_CUSTOMER_HASHKEY"
src_hashdiff: 
  source_column: "DV_FAKECUSTOMER__HASHDIFF"
  alias: "HASHDIFF"
src_payload:
    - Fake_Address
src_ldts: "DV_LOAD_DATE"
src_source: "DV_RECORD_SOURCE"
src_extra_columns:
    - DV_APPLIED_DATE
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