import boto3
from botocore.exceptions import ClientError
import ast

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

import snowflake.connector
import pandas as pd

# Thông tin kết nối
conn = snowflake.connector.connect(
    user='mankay1805',
    password='CHungpro$$12',
    account='EDDTNTH-YJ64905',
    warehouse='',
    database='binance_database_dev',
    schema='RAW',
    role='ACCOUNTADMIN'
)

query = """
SELECT parse_json(SYSTEM$PIPE_STATUS('CURRENT_PRICE_PIPE')) AS pipe_status;
"""
df = pd.read_sql(query, conn)

df['PIPE_STATUS'][0]

import json

final_dict = json.loads(df['PIPE_STATUS'][0])

sqs_arn = final_dict['notificationChannelName']

print(sqs_arn)

conn.close()

import boto3
import json

# Thông tin kết nối AWS S3 và SQS
s3_client = boto3.client(
    's3'
)

notification_configuration = {
    'QueueConfigurations': [
        {
            'Id': 'snowflake_sqs',
            'QueueArn': sqs_arn,
            'Events': ['s3:ObjectCreated:Copy'],
            'Filter': {
                'Key': {
                    'FilterRules': [
                        {'Name': 'Prefix', 'Value': ''},
                        {'Name': 'Suffix', 'Value': ''}
                    ]
                }
            }
        }
    ]
}

s3_noti = s3_client.get_bucket_notification_configuration(Bucket="stream-binance-from-ed")

for i in s3_noti:
    if i == 'QueueConfigurations':
        if s3_noti['QueueConfigurations'][0]['QueueArn'] == sqs_arn:
            print("SQS already exists") 
    else:
        print("Start to put SQS notification configuration")
        s3_client.put_bucket_notification_configuration(
            Bucket="stream-binance-from-ed", 
            NotificationConfiguration={
                'QueueConfigurations': [
                    {
                        'Id': 'Snowflake_sqs',
                        'QueueArn': sqs_arn,
                        'Events': ['s3:ObjectCreated:Copy'],
                        'Filter': {
                            'Key': {
                                'FilterRules': [
                                    {
                                        'Name': 'Prefix',  # Hoặc 'Suffix' tùy vào nhu cầu
                                        'Value': ''
                                    },
                                    {
                                        'Name': 'Suffix',  # Hoặc chỉ sử dụng 'Prefix'
                                        'Value': ''
                                    }
                                ]
                            }
                        }
                    }
                ]
            }
        )
        print("SQS created")


            