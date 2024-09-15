# snowpipe.py
import boto3
import snowflake.connector
import pandas as pd
import ast
from botocore.exceptions import ClientError
import json

# get secret from aws secret manager
def get_secret():
    secret_name = "snowflake_credential"
    region_name = "ap-southeast-2"

    # create a secret manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise e

    secret = ast.literal_eval(get_secret_value_response['SecretString'])
    return secret

# get arn of sqs snowpipe
def get_sqs_arn():
    secret = get_secret()

    # setup connection to snowflake
    conn = snowflake.connector.connect(
        user=secret['login'],
        password=secret['password'],
        account=secret['account'],
        warehouse='',
        database='binance_database_dev',
        schema='RAW',
        role=secret['role']
    )

    query = """
    SELECT parse_json(SYSTEM$PIPE_STATUS('CURRENT_PRICE_PIPE')) AS pipe_status;
    """
    df = pd.read_sql(query, conn)['PIPE_STATUS'][0]

    sqs_arn =json.loads(df)['notificationChannelName']

    conn.close()

    return sqs_arn

# assign sqs to s3 bucket
def attach_sqs_to_s3():
    s3_client = boto3.client('s3')
    bucket_name = "stream-binance-from-ed-4"

    # Lấy cấu hình thông báo hiện tại của S3
    s3_noti = s3_client.get_bucket_notification_configuration(Bucket=bucket_name)

    for i in s3_noti:
        if i == 'QueueConfigurations':
            if s3_noti['QueueConfigurations'][0]['QueueArn'] == get_sqs_arn():
                print("SQS already exists")
                return
        else:
            print("Start to put SQS notification configuration")
            s3_client.put_bucket_notification_configuration(
                Bucket=bucket_name, 
                NotificationConfiguration={
                    'QueueConfigurations': [
                        {
                            'Id': 'Snowflake_sqs',
                            'QueueArn': get_sqs_arn(),
                            'Events': ['s3:ObjectCreated:*'],
                            'Filter': {
                                'Key': {
                                    'FilterRules': [
                                        {
                                            'Name': 'Prefix',
                                            'Value': ''
                                        },
                                        {
                                            'Name': 'Suffix',
                                            'Value': ''
                                        }
                                    ]
                                }
                            }
                        }
                    ]
                }
            )
            print("SQS created attach on S3 bucket")
