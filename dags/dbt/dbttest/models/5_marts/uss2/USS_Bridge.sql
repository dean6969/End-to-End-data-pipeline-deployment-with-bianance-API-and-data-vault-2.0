{{ dbt_utils.union_relations(
    relations=[
        ref('USS_Account_Detail')
        ,ref('USS_Customer')
        ,ref('USS_Date')
        ,ref('USS_Stock')
        ,ref('USS_Stock_Account_Detail')
        ,ref('USS_Time')
        ],
    include=[
        "_KEY_Account_Detail"
        ,"_KEY_CUSTOMER"
        ,"_KEY_DATE"
        ,"_KEY_STOCK"
        ,"_KEY_Stock_Account_Detail"
        ,"_KEY_TIME"
        ],
    source_column_name="Stage"
) }}