import json
import uuid
from datetime import datetime
from time import sleep, time
import boto3
from botocore.exceptions import ClientError
from binance.client import Client
import ast

def pull_binance_current_price_data():
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
    client = Client(api_key, api_secret)

    # Lấy thông tin về giá hiện tại của tất cả các cặp giao dịch
    tickers = client.get_all_tickers()

    # Tạo danh sách chứa giá hiện tại của các cặp giao dịch

    # Thời gian hiện tại
    count = 0
    for ticker in tickers:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        price_info = {
            'id': str(uuid.uuid4()),
            'symbol': ticker['symbol'],
            'price': float(ticker['price']),
            'timestamp': timestamp  # Thời gian lấy giá
        }

        params = {
                'Data': json.dumps(price_info),
                'PartitionKey': 'current_price',
                'StreamName': stream_name
                }

        try:
            response = kinesis.put_record(**params)
            print(response)
        except Exception as e:
            print(e)

        sleep(1)
        count += 1
        if count == 20:
            break
