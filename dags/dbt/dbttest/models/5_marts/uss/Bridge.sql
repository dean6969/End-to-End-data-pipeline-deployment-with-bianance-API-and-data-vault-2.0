{{ dbt_utils.union_relations(
    relations=[
        ref('stg_Sample_TPCHSF1__CUSTOMER')
        ,ref('stg_Sample_TPCHSF1__ORDERS')
        ],
    include=["_KEY_CUSTOMER","_KEY_ORDER"],
    source_column_name="Stage"
) }}