from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
from pulling_current_price import pull_binance_current_price_data
from pulling_price_line_item import pull_binance_price_line_item_data

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email': ['your_email@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    schedule_interval="* 9 * * 1-5",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="ETL_PIPELINE_DATA_MODELING"
)

t1 = PythonOperator(
    task_id='pull_data_from_binance',
    python_callable=pull_binance_current_price_data,
    dag=dag,
)

t2 = PythonOperator(
    task_id='pull_price_line_item',
    python_callable=pull_binance_price_line_item_data,
    dag=dag,
)

t1

t2