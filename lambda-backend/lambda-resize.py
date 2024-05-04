import boto3
import subprocess
import os, tempfile

def handler(event, context):
    bucket = event['s3']
    key = event['keyPhoto']
    idPhoto = event['idPhoto']
    username = event['username']   
    ts= event['ts']
    
    s3 = boto3.client('s3')
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)

    response = s3.get_object(
        Bucket=bucket,
        Key=key,
    )
    image = response['Body'].read()

    if image is None:
        raise Exception("Image not found")

    with tempfile.NamedTemporaryFile() as original_image:
        original_image.write(image)

        with tempfile.NamedTemporaryFile(suffix=".webp") as compressed_image:

            convert_command = ['convert', original_image.name, '-resize', '1440x1440', '-quality', '75', compressed_image.name]
            conversion_process = subprocess.run(convert_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            if conversion_process.returncode == 0 and os.path.getsize(compressed_image.name) > 0:
                compBucket = os.environ['COMP_BUCKET']
                s3.upload_file(compressed_image.name, compBucket, idPhoto+'-comp.webp')
            else:
               
                error_message = conversion_process.stderr.decode('utf-8')
                raise Exception(f"Error during image conversion: {error_message}")

        with tempfile.NamedTemporaryFile(suffix=".webp") as thumbnail_image:
            
            convert_command = ['convert', original_image.name, '-resize', '350x350', '-quality', '75', thumbnail_image.name]
            conversion_process = subprocess.run(convert_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            if conversion_process.returncode == 0 and os.path.getsize(thumbnail_image.name) > 0:
                thumbBucket = os.environ['Thumb_BUCKET']
                s3.upload_file(thumbnail_image.name, thumbBucket, idPhoto+'-thumb.webp')
            else:
               
                error_message = conversion_process.stderr.decode('utf-8')
                raise Exception(f"Error during image conversion: {error_message}")
    
    table.put_item(Item = {"ID-post": idPhoto, "username": username, "ts": ts, 'status': 'success', 'error': None})
    #s3.delete_object(Bucket=bucket, Key=key)
    
    return {
        'statusCode': 200,
        'body': 'Image converted successfully'
    }
   