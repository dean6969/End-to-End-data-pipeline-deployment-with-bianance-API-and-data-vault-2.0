import base64
import json
import boto3
from datetime import datetime

s3_client = boto3.client('s3')
bucket_name = 'stream-binance-from-ed-test1'


def lambda_handler(event, context):
    records = event['Records']

    # Initialize lists to hold data for each partition
    current_price_data = []
    price_line_item_data = []
    symbol_data = []

    print(f"Received {len(records)} Kinesis records")

    for record in records:
        data = record['kinesis']['data']

        decoded_data = base64.b64decode(data).decode('utf-8')

        print(record['kinesis'])

        # Convert the decoded data to a JSON object
        parsed_data = json.loads(decoded_data)

        print(f"Decoded data: {parsed_data}")

        # Check the partition key and append data to the corresponding list
        partition_key = record['kinesis']['partitionKey']

        print(f"Partition key: {partition_key}")
        print(partition_key == 'current_price')

        if partition_key == 'current_price':
            current_price_data.append(parsed_data)
            print(f"Decoded data: {current_price_data}")
            print(True)
        else:
            print(False)

        if partition_key == 'price_line_item':
            price_line_item_data.append(parsed_data)

        if partition_key == 'symbol':
            symbol_data.append(parsed_data)

        print(current_price_data)

    # Function to upload data to the appropriate folder
    def upload_to_s3(data_list, folder_name, key):
        for item in data_list:
            try:
                filename = f"{folder_name}/{key}_{datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%S-%f')}.json"
                print(filename)
                print(f"Uploading to S3 with key: {filename}")
                s3_client.put_object(Bucket=bucket_name, Key=filename, Body=json.dumps(item))
                print(f"Uploaded {filename} to S3")
            except Exception as e:
                print(f"Error uploading {filename}: {e}")

    # Upload data for each partition key to its respective folder if the list is not empty
    if current_price_data:
        upload_to_s3(current_price_data, 'landing_file/current_price', 'current_price')

    if price_line_item_data:
        upload_to_s3(price_line_item_data, 'landing_file/price_line_item', 'price_line_item')

    if symbol_data:
        upload_to_s3(symbol_data, 'landing_file/symbol', 'symbol')

    print("data successfully uploaded to S3")

    return {
        'statusCode': 200,
        'body': 'Success'
    }
