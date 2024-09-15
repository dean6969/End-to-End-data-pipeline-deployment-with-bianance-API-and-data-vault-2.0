import csv
import logging
import boto3
from botocore.exceptions import ClientError
import ast
from binance.client import Client
import uuid

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
csv_data = []

# Thêm tiêu đề cho CSV
csv_data.append(['id', 'symbol', 'status', 'baseAsset', 'quoteAsset'])

for symbol in exchange_info['symbols']:
    records = [
        str(uuid.uuid4()),  # id (UUID)
        symbol['symbol'],  # symbol
        symbol['status'],  # status
        symbol['baseAsset'],  # baseAsset
        symbol['quoteAsset']  # quoteAsset
    ]
    
    csv_data.append(records)

# Lưu tất cả các thông tin vào tệp CSV
with open('binance_symbols.csv', 'w', newline='', encoding='utf-8') as csv_file:
    writer = csv.writer(csv_file)
    writer.writerows(csv_data)

print("Dữ liệu đã được lưu vào tệp binance_symbols.csv.")
