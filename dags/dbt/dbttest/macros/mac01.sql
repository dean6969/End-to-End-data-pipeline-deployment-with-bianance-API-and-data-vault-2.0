{%- macro mac01(src_pk, src_ldts, src_source, source_model) -%}

{%- set source_cols = dbtvault.expand_column_list(columns=[src_pk, src_ldts, src_source]) -%}
{%- set window_cols = dbtvault.expand_column_list(columns=[src_pk, src_ldts,src_source]) -%}
{%- set source_cols2 = dbtvault.expand_column_list(columns=[src_pk,src_source]) -%}
{%- set pk_cols = dbtvault.expand_column_list(columns=[src_pk]) -%}


{%- if model.config.materialized == 'vault_insert_by_rank' %}
    {%- set source_cols_with_rank = source_cols + [config.get('rank_column')] -%}
{%- endif %}

WITH source_data AS (
    {%- if model.config.materialized == 'vault_insert_by_rank' %}
    SELECT {{ dbtvault.prefix(source_cols_with_rank, 'a', alias_target='source') }}
    {%- else %}
    SELECT {{ dbtvault.prefix(source_cols, 'a', alias_target='source') }}
    {%- endif %}
    FROM {{ ref(source_model) }} AS a
    WHERE {{ dbtvault.multikey(src_pk, prefix='a', condition='IS NOT NULL') }}
    {%- if model.config.materialized == 'vault_insert_by_period' %}
    AND __PERIOD_FILTER__
    {% elif model.config.materialized == 'vault_insert_by_rank' %}
    AND __RANK_FILTER__
    {% endif %}
),
{%- if dbtvault.is_any_incremental() %}

latest_records AS (
    SELECT {{ dbtvault.prefix(window_cols, 'a', alias_target='target') }},a.DV_STATUS
    FROM (
        SELECT {{ dbtvault.prefix(window_cols, 'current_records', alias_target='target') }},current_records.DV_STATUS,
            RANK() OVER (
               PARTITION BY {{ dbtvault.prefix([src_pk], 'current_records') }}
               ORDER BY {{ dbtvault.prefix([src_ldts], 'current_records') }} DESC
            ) AS rank
        FROM {{ this }} AS current_records
    ) AS a
    WHERE a.rank = 1
),

{%- endif %}
Irecords AS (
    SELECT DISTINCT {{ dbtvault.alias_all(source_cols2, 'stage') }}
        , 'I' as "DV_STATUS"
        , stage.DV_LOAD_DATE
    FROM source_data AS stage
    {%- if dbtvault.is_any_incremental() %}
    Where NOT EXISTS
    (
        select 1
        from latest_records
        where {{ dbtvault.multikey(src_pk, prefix=['latest_records','stage'], condition='=') }}
            AND latest_records."DV_STATUS" <> 'D'
    )
    {%- endif %}
)
{%- if dbtvault.is_any_incremental() %}
,Drecords AS (
    SELECT DISTINCT {{ dbtvault.alias_all(source_cols2, 'latest_records') }} 
        , 'D' as "DV_STATUS"
        , to_timestamp('{{ var('load_date') }}') as "DV_LOAD_DATE"
    FROM latest_records
    Where NOT EXISTS
    (
        select 1
        from  source_data AS stage
        where {{ dbtvault.multikey(src_pk, prefix=['latest_records','stage'], condition='=') }}
    )
    AND "DV_RECORD_SOURCE" <> 'DBTVAULT_SYSTEM'   
    AND "DV_STATUS" <> 'D'
)
{%- endif %}
,records_to_insert AS (
    select * from Irecords
    {%- if dbtvault.is_any_incremental() %}
    UNION ALL
    select * from Drecords
    {%- endif %}
)
SELECT * FROM records_to_insert
{%- endmacro -%}
