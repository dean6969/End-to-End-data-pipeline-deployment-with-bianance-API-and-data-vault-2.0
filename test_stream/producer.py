import json
import random
import time
import boto3

kinesis = boto3.client('kinesis', region_name='us-east-1')
stream_name = "KP1DataStream"

def generate_telemetry1():
    while True:
        temperature = 20 + random.random() * 10
        wind = random.random() * 10
        pressure = 980 + random.random() * 40
        telemetry = {'temperature': temperature, 'wind': wind, 'pressure': pressure}

        params = {
            'Data': json.dumps(telemetry),
            'PartitionKey': '1234',
            'StreamName': stream_name
        }

        try:
            response = kinesis.put_record(**params)
            print(response)
        except Exception as e:
            print(e)

        time.sleep(0.5)

generate_telemetry1()
