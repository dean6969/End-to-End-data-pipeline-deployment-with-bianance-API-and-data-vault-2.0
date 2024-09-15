# Lấy tất cả các tham số hiện tại của thị trường
import json
from datetime import datetime
import logging
import boto3
from botocore.exceptions import ClientError
import ast
from binance.client import Client
from time import sleep

# AWS Secrets Manager configuration
secret_name = "binace_api"
region_name = "us-east-1"

# Create a Secrets Manager client
session = boto3.session.Session()
secrets_client = session.client(
    service_name='secretsmanager',
    region_name=region_name
)

# Fetch API key and secret from Secrets Manager
try:
    get_secret_value_response = secrets_client.get_secret_value(
        SecretId=secret_name
    )
except ClientError as e:
    raise e

# kinesis data stream
stream_name = "stream_binance"
kinesis = boto3.client('kinesis', region_name='us-east-1')


secret = ast.literal_eval(get_secret_value_response['SecretString'])

# Binance API credentials
api_key = secret['api_key']
api_secret = secret['api_secret']

# Initialize Binance client
client = Client(api_key, api_secret)

# Configure logging
logging.basicConfig(filename='binance_logs.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

exchange_info = client.get_exchange_info()

# Tạo danh sách chỉ chứa các trường thông tin về cặp giao dịch

for symbol in exchange_info['symbols']:
    records = {
        'symbol': symbol['symbol'],
        'status': symbol['status'],
        'baseAsset': symbol['baseAsset'],
        'quoteAsset': symbol['quoteAsset']
    }

    params = {
        'Data': json.dumps(records),
        'PartitionKey': 'symbol',
        'StreamName': stream_name
    }

    try:
        response = kinesis.put_record(**params)
        print(response)
    except Exception as e:
        print(e)

    sleep(7)