{%- set yaml_metadata -%}
source_model: "hstg_tpch__account_position"
src_pk: "DV_CUSTOMER_HASHKEY"
src_hashdiff: 
  source_column: "DV_CUSTOMER_RECORD_HASHDIFF"
  alias: "HASHDIFF"
src_ldts: "DV_LOAD_DATE"
src_source: "DV_RECORD_SOURCE"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ dbtvault.sat(src_pk=metadata_dict["src_pk"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_ldts=metadata_dict["src_ldts"],
                src_source=metadata_dict["src_source"],
                source_model=metadata_dict["source_model"]
                )
                }}