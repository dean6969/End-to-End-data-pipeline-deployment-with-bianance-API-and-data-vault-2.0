import json
import uuid
from datetime import datetime, timedelta
import logging
import boto3
from botocore.exceptions import ClientError
from binance.client import Client
import ast
from time import sleep, time

# Setup initial timing
start_time = time()

# AWS Secrets Manager configuration
secret_name = "binance_api"  # Corrected typo in secret name
region_name = "us-east-1"

# Create a Secrets Manager client
session = boto3.session.Session()
secrets_client = session.client(
    service_name='secretsmanager',
    region_name=region_name
)

# Configure logging
logging.basicConfig(filename='binance_logs.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

try:
    get_secret_value_response = secrets_client.get_secret_value(SecretId=secret_name)
    secret = ast.literal_eval(get_secret_value_response['SecretString'])
except ClientError as e:
    logging.error(f"Failed to retrieve secrets: {str(e)}")
    raise

# Binance API credentials
api_key = secret['api_key']
api_secret = secret['api_secret']

# Initialize Binance client
client = Client(api_key, api_secret)

# kinesis data stream
stream_name = "stream_binance"
kinesis = boto3.client('kinesis', region_name=region_name)

# Fetch exchange information (symbols and assets)
try:
    exchange_info = client.get_exchange_info()
    symbols = [symbol['symbol'] for symbol in exchange_info['symbols']]
except Exception as e:
    logging.error(f"Failed to fetch exchange info: {str(e)}")
    raise

# Define the end time for the loop to run (200 seconds from start)
end_time = start_time + 200

def pull_data_price_line_item():

    # Loop over symbols and fetch kline data for each
    for symbol in symbols:
        if time() > end_time:
            logging.info("200 seconds have elapsed. Stopping the data fetch loop.")
            break  # Exit the loop after 200 seconds
        
        try:
            # Fetch the most recent 1-day kline for the symbol
            klines = client.get_klines(symbol=symbol, interval=Client.KLINE_INTERVAL_1DAY, limit=1)
            for kline in klines:
                kline_info = {
                    'id': str(uuid.uuid4()),
                    "symbol": symbol,
                    "open_time": datetime.fromtimestamp(kline[0]/1000).isoformat(),
                    "open_price": kline[1],
                    "high_price": kline[2],
                    "low_price": kline[3],
                    "close_price": kline[4],
                    "volume": kline[5],
                    "close_time": datetime.fromtimestamp(kline[6]/1000).isoformat(),
                    "quote_asset_volume": kline[7],
                    "number_of_trades": kline[8],
                    "taker_buy_base_asset_volume": kline[9],
                    "taker_buy_quote_asset_volume": kline[10],
                }

                params = {
                    'Data': json.dumps(kline_info),
                    'PartitionKey': 'price_line_item',
                    'StreamName': stream_name
                }

                response = kinesis.put_record(**params)
                logging.info(f"Record sent to Kinesis: {response}")

        except Exception as e:
            logging.error(f"Failed processing symbol {symbol}: {str(e)}")
            continue

        sleep(1)  # Throttle the API requests to avoid hitting limits
