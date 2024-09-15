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
from snowpipe_integration_noti import attach_sqs_to_s3

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


def get_aws_secret():
    secret_name = "aws_key"
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

##
secret = get_secret()
aws_secret = get_aws_secret()


###################################### SNOWFLAKE CONNECTION SETUP ########################################
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

###################################### SETUP DAG ########################################
@dag(
    schedule_interval="* 8 * * 1-5",
    start_date=datetime(2023, 1, 1),
    catchup=False
)
def snowflake_setup_dag():

    # Task to setup the Snowflake connection
    setup_snowflake_connection_task = PythonOperator(
        task_id="setup_snowflake_connection",
        python_callable=setup_snowflake_connection
    )

    # Task to read sql file for ddl step
    with open("/opt/airflow/dags/ddl_scripts/ddl_datawarehouse.sql", 'r') as file:
        create_warehouse = file.read()

    with open("/opt/airflow/dags/ddl_scripts/ddl_database.sql", 'r') as file:
        create_database = file.read()
    
    with open("/opt/airflow/dags/ddl_scripts/ddl_schema.sql", 'r') as file:
        create_schema = file.read()

    with open("/opt/airflow/dags/ddl_scripts/dll_table_in_raw_schema.sql", 'r') as file:
        create_table = file.read()

    create_warehouse_task = SnowflakeOperator(
        task_id="create_warehouse",
        snowflake_conn_id="sf_test",
        sql=create_warehouse
    )

    # Task to create the database
    create_database_task = SnowflakeOperator(
        task_id="create_database",
        snowflake_conn_id="sf_test",
        sql=create_database
    )

    # Task to create the schema
    create_schema_task = SnowflakeOperator(
        task_id="create_schema",
        snowflake_conn_id="sf_test",
        sql=create_schema
    )

    # Task to create the table
    create_table_task = SnowflakeOperator(
        task_id="create_table",
        snowflake_conn_id="sf_test",
        sql=create_table
    )

    # Task to create the external stage
    create_external_stage = f"""
    USE DATABASE binance_database_dev;

    USE SCHEMA RAW;

    CREATE OR REPLACE STAGE s3_json_stage
    URL = 's3://stream-binance-from-ed/'
    CREDENTIALS = (AWS_KEY_ID = '{aws_secret['access_key_id']}' AWS_SECRET_KEY = '{aws_secret['secret_key_id']}')
    FILE_FORMAT = (TYPE = 'JSON');
    """
    # Task to create the external stage
    create_external_stage_task = SnowflakeOperator(
        task_id="create_external_stage",
        snowflake_conn_id="sf_test",
        sql=create_external_stage
    )

    # Task to create the snowpipe
    with open("/opt/airflow/dags/ddl_scripts/ddl_snowpipe.sql", 'r') as file:
        create_snowpipe = file.read()

    create_snowpipe_task = SnowflakeOperator(
        task_id="create_snowpipe",
        snowflake_conn_id="sf_test",
        sql=create_snowpipe
    )

    setup_snowpipe_notification_task = PythonOperator(
        task_id="setup_snowpipe_notification",
        python_callable=attach_sqs_to_s3
    )


    
    # Task dependencies: warehouse -> database -> schemas -> tables
    setup_snowflake_connection_task >> create_warehouse_task >> create_database_task >> create_schema_task >> create_table_task

    create_table_task >> create_external_stage_task >> create_snowpipe_task >> setup_snowpipe_notification_task

# Instantiate the DAG
snowflake_setup_dag = snowflake_setup_dag()
