from airflow.decorators import dag
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
from pulling_current_price import pull_binance_current_price_data
from pulling_price_line_item import pull_data_price_line_item
from airflow.operators.dummy_operator import DummyOperator

@dag(
    schedule_interval="* 9 * * 1-5",
    start_date=datetime(2023, 1, 1),
    catchup=False
)
def pulling_api_to_kinesis():

    t0 = DummyOperator(
        task_id='dummy_task',
    )   
    

    t1 = PythonOperator(
        task_id='pull_data_from_binance',
        python_callable=pull_binance_current_price_data,
    )

    t2 = PythonOperator(
        task_id='pull_price_line_item',
        python_callable=pull_data_price_line_item,
    )

    t0 >> t1 

    t0 >> t2

pulling_api_to_kinesis = pulling_api_to_kinesis()