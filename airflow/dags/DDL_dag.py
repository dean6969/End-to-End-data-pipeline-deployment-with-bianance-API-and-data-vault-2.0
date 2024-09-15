import os
from airflow import settings
from airflow.models import Connection
from airflow.decorators import dag
from airflow.operators.python import PythonOperator
from snowflake import connector
from datetime import datetime
import boto3
from botocore.exceptions import ClientError
import ast
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.decorators import dag
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from datetime import datetime

def get_secret():

    secret_name = "snowflake_credential"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = ast.literal_eval(get_secret_value_response['SecretString'])

    return secret
secret = get_secret()


def setup_snowflake_connection():
    # Check if the connection already exists
    conn_id = "sf_test"
    session = settings.Session()
    existing_conn = session.query(Connection).filter(Connection.conn_id == conn_id).first()
    
    if not existing_conn:
        # If the connection does not exist, create it
        conn = Connection(
            conn_id=conn_id,
            conn_type=secret['conn_type'],
            login=secret['login'],
            password=secret['password'],
            extra={"account": secret['account'],"role": secret['role']}
        )
        session.add(conn)
        session.commit()
        print(f"Connection '{conn_id}' created successfully.")
    else:
        print(f"Connection '{conn_id}' already exists.")
    session.close()



# Define SQL queries










# Define the DAG
@dag(
    schedule_interval="*/2 * * * *",
    start_date=datetime(2023, 1, 1),
    catchup=False
)
def snowflake_setup_dag():

    setup_snowflake_connection_task = PythonOperator(
        task_id='setup_snowflake_connection',
        python_callable=setup_snowflake_connection
    )
######################################################### WAREHOUSE SNOWFLAKE #########################################################
    warehouse_sql = """
    CREATE WAREHOUSE IF NOT EXISTS binance_warehouse_dev
    WITH WAREHOUSE_SIZE = 'LARGE'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 10
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;
    """


    # Task to create the warehouse
    create_warehouse_task = SnowflakeOperator(
        task_id="create_warehouse",
        snowflake_conn_id="sf_test",  # Connection ID set in Airflow
        sql=warehouse_sql
    )
######################################################### DATABASE SNOWFLAKE #########################################################
    database_sql = """
    USE WAREHOUSE binance_warehouse_dev;

    CREATE DATABASE IF NOT EXISTS binance_database_dev;

    """

    # Task to create the database
    create_database_task = SnowflakeOperator(
        task_id="create_database",
        snowflake_conn_id="sf_test",
        sql=database_sql
    )
######################################################### SCHEMA SNOWFLAKE #########################################################  

    raw_schema_sql = """
    USE WAREHOUSE binance_warehouse_dev;

    USE DATABASE binance_database_dev;

    CREATE SCHEMA IF NOT EXISTS raw;
    """
    staging_schema_sql = """
    USE WAREHOUSE binance_warehouse_dev;

    USE DATABASE binance_database_dev;

    CREATE SCHEMA IF NOT EXISTS staging;
    """
    silver_schema_sql = """
    USE WAREHOUSE binance_warehouse_dev;

    USE DATABASE binance_database_dev;

    CREATE SCHEMA IF NOT EXISTS silver;
    """
    gold_schema_sql = """
    USE WAREHOUSE binance_warehouse_dev;

    USE DATABASE binance_database_dev;

    CREATE SCHEMA IF NOT EXISTS gold;
    """
    # Task to create raw schema
    create_raw_schema_task = SnowflakeOperator(
        task_id="create_raw_schema",
        snowflake_conn_id="sf_test",
        sql=raw_schema_sql
    )
    
    # Task to create staging schema
    create_staging_schema_task = SnowflakeOperator(
        task_id="create_staging_schema",
        snowflake_conn_id="sf_test",
        sql=staging_schema_sql
    )
    
    # Task to create silver schema
    create_silver_schema_task = SnowflakeOperator(
        task_id="create_silver_schema",
        snowflake_conn_id="sf_test",
        sql=silver_schema_sql
    )
    
    # Task to create gold schema
    create_gold_schema_task = SnowflakeOperator(
        task_id="create_gold_schema",
        snowflake_conn_id="sf_test",
        sql=gold_schema_sql
    )
######################################################### RAW TABLE SNOWFLAKE #########################################################
    raw_symbol = """

    USE DATABASE binance_database_dev;

    CREATE TABLE IF NOT EXISTS raw_symbol_data (
        symbol VARCHAR(255),
        status VARCHAR(50),
        baseAsset VARCHAR(255),
        quoteAsset VARCHAR(255),
        load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    raw_price_line_item = """
    USE DATABASE binance_database_dev;

    CREATE TABLE IF NOT EXISTS raw_price_line_item_data (
        symbol VARCHAR(255),
        open_time TIMESTAMP,
        open_price DECIMAL(18, 6),
        high_price DECIMAL(18, 6),
        low_price DECIMAL(18, 6),
        close_price DECIMAL(18, 6),
        volume DECIMAL(18, 6),
        close_time TIMESTAMP,
        quote_asset_volume DECIMAL(18, 6),
        number_of_trades INT,
        taker_buy_base_asset_volume DECIMAL(18, 6),
        taker_buy_quote_asset_volume DECIMAL(18, 6),
        load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    raw_current_price = """
    USE DATABASE binance_database_dev;

    CREATE TABLE IF NOT EXISTS raw_current_price_data (
        symbol VARCHAR(255),
        price DECIMAL(18, 6),
        timestamp TIMESTAMP,
        load_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    create_raw_symbol_task = SnowflakeOperator(
        task_id="create_raw_symbol",
        snowflake_conn_id="sf_test",
        sql=raw_symbol
    )

    create_raw_price_line_item_task = SnowflakeOperator(
        task_id="create_raw_price_line_item",
        snowflake_conn_id="sf_test",
        sql=raw_price_line_item
    )

    create_raw_current_price_task = SnowflakeOperator(
        task_id="create_raw_current_price",
        snowflake_conn_id="sf_test",
        sql=raw_current_price
    )

    trigger_dag2 = TriggerDagRunOperator(
        task_id='trigger_deploy_dw',
        trigger_dag_id='basic_cosmos_task_group',
        wait_for_completion=True,
        reset_dag_run=True # Tên của DAG thứ hai
    )

######################################################### EXTERNAL STAGE #########################################################

    
    # Task dependencies: warehouse -> database -> schemas -> tables
    setup_snowflake_connection_task >> create_warehouse_task >> create_database_task >> create_raw_schema_task 

    create_database_task >> create_staging_schema_task 

    create_database_task >> create_silver_schema_task 

    create_database_task >> create_gold_schema_task

    create_raw_schema_task >> create_raw_symbol_task

    create_raw_schema_task >> create_raw_price_line_item_task

    create_raw_schema_task >> create_raw_current_price_task

    create_raw_symbol_task >> trigger_dag2
    create_raw_price_line_item_task >> trigger_dag2
    create_raw_current_price_task >> trigger_dag2

# Instantiate the DAG
snowflake_setup_dag = snowflake_setup_dag()
