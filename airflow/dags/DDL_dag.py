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
    schedule_interval="* 8 * * 1-5",
    start_date=datetime(2023, 1, 1),
    catchup=False
)
def snowflake_setup_dag():

    with open("ddl_scripts/ddl_datawarehouse.sql", 'r') as file:
        create_warehouse = file.read()

    with open("ddl_scripts/ddl_database.sql", 'r') as file:
        create_database = file.read()
    
    with open("ddl_scripts/ddl_schema.sql", 'r') as file:
        create_schema = file.read()

    with open("ddl_scripts/ddl_table.sql", 'r') as file:
        create_table = file.read()

    create_warehouse_task = SnowflakeOperator(
        task_id="create_warehouse",
        snowflake_conn_id="sf_test",
        sql=create_warehouse
    )

    create_database_task = SnowflakeOperator(
        task_id="create_database",
        snowflake_conn_id="sf_test",
        sql=create_database
    )

    create_schema_task = SnowflakeOperator(
        task_id="create_schema",
        snowflake_conn_id="sf_test",
        sql=create_schema
    )

    create_table_task = SnowflakeOperator(
        task_id="create_table",
        snowflake_conn_id="sf_test",
        sql=create_table
    )




    
    # Task dependencies: warehouse -> database -> schemas -> tables
    setup_snowflake_connection_task >> create_warehouse_task >> create_database_task >> create_schema_task >> create_table_task

# Instantiate the DAG
snowflake_setup_dag = snowflake_setup_dag()
