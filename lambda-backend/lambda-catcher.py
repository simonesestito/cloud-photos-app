import boto3
import os

def lambda_handler(event, context):
    bucket = event['s3']
    key = event['keyPhoto']
    region = os.environ['REGION']
    idPhoto = event['idPhoto']
    username = event['username']   
    ts = event['ts']
    error = event['error']


    s3 = boto3.client('s3', region_name=region)
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)

    table.put_item(Item = {"ID-post": idPhoto, "username": username, "ts": ts, 'status': 'failed', 'error': error})

    return event