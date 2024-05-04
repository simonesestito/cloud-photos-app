import boto3
import os

def lambda_handler(event, context):
    bucket = event['s3']
    key = event['keyPhoto']
    region = os.environ['REGION']
    idPhoto = event['idPhoto']
    username = event['username']   
    ts= event['ts']


    s3 = boto3.client('s3', region_name=region)
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)

    response = table.get_item(
        Key={
            'ID-post': idPhoto
        }
    )
    
    
    if not issuffix(key):
        raise Exception("Invalid file suffix")

    table.put_item(Item = {"ID-post": idPhoto, "username": username, "ts": ts, 'status': 'pending', 'error': None})

    rekognition = boto3.client('rekognition', region_name=region)
    detectModerationLabelsResponse = rekognition.detect_moderation_labels(
    Image={
       'S3Object': {
           'Bucket': bucket,
           'Name': key,
       }
    }
)
    #ritorna una lista di labels
    moderationLabels = detectModerationLabelsResponse['ModerationLabels']
    
        
    if len(moderationLabels):
       raise Exception("Image moderation labels detected")

    

    return event

def issuffix(filename):
    suffixes = ['jpg', 'jpeg', 'png', 'gif']
    suffix = filename.split('.')[-1]   
    return suffix in suffixes