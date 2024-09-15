select  
    data:id::STRING as id
    ,data:symbol::STRING as symbol
    ,data:open_time::TIMESTAMP as open_time
    ,data:open_price::FLOAT as open_price
    ,data:high_price::FLOAT as high_price
    ,data:low_price::FLOAT as low_price
    ,data:close_price::FLOAT as close_price
    ,data:volume::FLOAT as volume
    ,data:close_time::TIMESTAMP as close_time
    ,data:quote_asset_volume::FLOAT as quote_asset_volume
    ,data:number_of_trades::FLOAT as number_of_trades
    ,data:taker_buy_base_asset_volume::FLOAT as taker_buy_base_asset_volume
    ,data:taker_buy_quote_asset_volume::FLOAT as taker_buy_quote_asset_volume
    ,load_datetime
from {{ source('RAW_TABLE', 'LANDING_PRICE_LINE_ITEM') }}