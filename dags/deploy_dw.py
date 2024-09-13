from datetime import datetime
import os
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig, DbtDepsLocalOperator, DbtTaskGroup
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
from airflow import settings
from airflow.models import Connection
from airflow.operators.python import PythonOperator
# from airflow import DAG
from airflow.decorators import dag

# dag = DAG(
#     dag_id="main_dag",
#     default_args={ 'start_date': datetime(2023, 9, 6)},
#     schedule_interval="@daily",
#     catchup=False
# )


profile_config = ProfileConfig(profile_name="dbtvault_snowflake_demo",
                               target_name="dev",
                               profile_mapping=SnowflakeUserPasswordProfileMapping(conn_id="sf_test", 
                                                    profile_args={
                                                        "database": "DV_TEST",
                                                        "schema": "STAGE"
                                                        },
                                                    ))


def setup_snowflake_connection():
    # Check if the connection already exists
    conn_id = "sf_test"
    session = settings.Session()
    existing_conn = session.query(Connection).filter(Connection.conn_id == conn_id).first()
    
    if not existing_conn:
        # If the connection does not exist, create it
        conn = Connection(
            conn_id=conn_id,
            schema="STAGE",
            conn_type="snowflake",
            login="mankay1805",
            password="CHungpro$$12",
            extra={"account": "EDDTNTH-YJ64905", "warehouse": "LARGE_WH", "role": "ACCOUNTADMIN", "database": "DV_TEST"}
        )
        session.add(conn)
        session.commit()
        print(f"Connection '{conn_id}' created successfully.")
    else:
        print(f"Connection '{conn_id}' already exists.")
    session.close()





# dbt_snowflake_dag = DbtDag(project_config=ProjectConfig("/opt/airflow/dags/dbt/dbttest",),
#                     operator_args={"install_deps": True},
#                     profile_config=profile_config,
#                     execution_config=ExecutionConfig(dbt_executable_path="./dbt_venv/bin/dbt",),
#                     schedule_interval="@daily",
#                     start_date=datetime(2023, 9, 6),
#                     catchup=False,
#                     dag_id="dbt_snowflake_dag_1")

@dag(
    schedule_interval="0 8 * * 1-5",
    start_date=datetime(2023, 1, 1),
    catchup=False
)
def basic_cosmos_task_group() -> None:
    # Task to set up Snowflake connection
    setup_connection_task = PythonOperator(
        task_id='setup_snowflake_connection',
        python_callable=setup_snowflake_connection
    )

    dbt_snowflake_dag = DbtTaskGroup(
        group_id="snowflake_transform",
        project_config=ProjectConfig("/opt/airflow/dags/dbt/dbttest"),
        execution_config=ExecutionConfig(dbt_executable_path="./dbt_venv/bin/dbt",),
        operator_args={"install_deps": True},
        profile_config=profile_config,
    )

    setup_connection_task >> dbt_snowflake_dag

basic_cosmos_task_group()