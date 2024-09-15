import json
import uuid
from datetime import datetime
from time import sleep, time
import boto3
from botocore.exceptions import ClientError
from binance.client import Client
import ast

def pull_binance_current_price_data():
    secret_name = "binace_api"
    region_name = "us-east-1"

    # Setup AWS Secrets Manager client
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # Fetch API key and secret from Secrets Manager
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise e

    secret = ast.literal_eval(get_secret_value_response['SecretString'])

    # Binance API credentials
    api_key = secret['api_key']
    api_secret = secret['api_secret']
    client = Client(api_key, api_secret)

    # Setup Kinesis client
    stream_name = "stream_binance"
    kinesis = boto3.client('kinesis', region_name='us-east-1')

    # Get current prices from Binance API
    tickers = client.get_all_tickers()

    # Define the end time for the loop to run
    end_time = time() + 200  # 200 seconds from now

    # Loop to pull data and send to Kinesis
    while time() < end_time:
        for ticker in tickers:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            price_info = {
                'id': str(uuid.uuid4()),
                'symbol': ticker['symbol'],
                'price': float(ticker['price']),
                'timestamp': timestamp
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

            sleep(5)  # Pause for 5 seconds
