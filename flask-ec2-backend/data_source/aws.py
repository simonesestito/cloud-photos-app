import pathlib
import uuid
import json
from collections import defaultdict
from typing import Optional, List
from datetime import datetime

import boto3
from mypy_boto3_dynamodb import DynamoDBClient
from mypy_boto3_s3 import S3Client
from mypy_boto3_stepfunctions import SFNClient

from data_source.interface import IUserDataSource, IPhotoDataSource
from model import User, UserSummary, PhotoUploadResult

AWS_REGION = 'us-east-1'
AWS_POST_TABLE_NAME = 'post-table'
AWS_USERS_SEARCH_INDEX_NAME = 'username-search'
AWS_POSTS_SEARCH_INDEX_NAME = 'posts-search'


class AwsUserDataSource(IUserDataSource):
    def __init__(self) -> None:
        self.dynamodb: DynamoDBClient = boto3.client('dynamodb', region_name=AWS_REGION)

    def search_user(self, username_prefix: str) -> List[UserSummary]:
        response = self.dynamodb.query(
            TableName=AWS_POST_TABLE_NAME,
            IndexName=AWS_USERS_SEARCH_INDEX_NAME,
            KeyConditionExpression='begins_with(#username, :username) AND #state = :state',
            ExpressionAttributeNames={
                '#state': 'state',
                '#username': 'username',
            },
            ExpressionAttributeValues={
                ':username': {'S': username_prefix},
                ':state': {'S': 'success'}
            },
            Select='SPECIFIC_ATTRIBUTES',
            ProjectionExpression='#username, #state',
        )

        # Count the posts for each found user
        username_posts_count = defaultdict(lambda: 0)
        for item in response.get('Items', []):
            username = item['username']['S']
            username_posts_count[username] += 1

        # Return them as UserSummary
        return sorted([
            UserSummary(
                username=username,
                posts_count=posts_count,
            )
            for username, posts_count in username_posts_count.items()
        ], key=lambda user: user.username)

    def get_user_by_username(self, username: str) -> Optional[User]:
        response = self.dynamodb.query(
            TableName=AWS_POST_TABLE_NAME,
            IndexName=AWS_POSTS_SEARCH_INDEX_NAME,
            KeyConditionExpression='#username = :username AND #state = :state',
            ExpressionAttributeNames={
                '#state': 'state',
                '#username': 'username',
                '#id': 'ID-post',
            },
            ExpressionAttributeValues={
                ':username': {'S': username},
                ':state': {'S': 'success'},
            },
            Select='SPECIFIC_ATTRIBUTES',
            ProjectionExpression='#username, #state, #id',
        )

        # Handle user not found
        items_count = response.get('Count', 0)
        if items_count == 0:
            return None

        items_found = response.get('Items', [])
        return User(
            username=username,
            post_ids=[
                item['ID-post']['S']
                for item in items_found
            ]
        )


AWS_UPLOAD_PHOTOS_BUCKET = 'images-to-resize'
AWS_PROCESSING_STEP_FUNCTION_ARN = 'arn:aws:states:us-east-1:061197399749:stateMachine:MyStateMachine-yvl2mnamm'


class AwsPhotoDataSource(IPhotoDataSource):
    def __init__(self) -> None:
        self.dynamodb: DynamoDBClient = boto3.client('dynamodb', region_name=AWS_REGION)
        self.s3: S3Client = boto3.client('s3', region_name=AWS_REGION)
        self.stepfunctions: SFNClient = boto3.client('stepfunctions', region_name=AWS_REGION)

    def upload_photo(self, username: str, file: pathlib.Path) -> PhotoUploadResult:
        photo_id = AwsPhotoDataSource._generate_photo_id()
        photo_filename = f'{photo_id}{file.suffix}'  # Keep the same file extension
        timestamp = AwsPhotoDataSource._generate_timestamp()

        # Upload to S3 bucket
        self.s3.upload_file(str(file.resolve().absolute()), AWS_UPLOAD_PHOTOS_BUCKET, photo_filename)

        # Begin processing
        self.stepfunctions.start_execution(
            stateMachineArn=AWS_PROCESSING_STEP_FUNCTION_ARN,
            name=f'photo_upload_processing_{photo_id}',
            input=json.dumps({
                'username': username,
                's3': AWS_UPLOAD_PHOTOS_BUCKET,
                'idPhoto': photo_id,
                'keyPhoto': photo_filename,
                'ts': timestamp,
            })
        )

        return PhotoUploadResult(
            photo_id=photo_id,
            status='PENDING',
            timestamp=timestamp,
            author_username=username,
        )

    def get_photo_upload(self, photo_id: str) -> PhotoUploadResult:
        # Get the status from the DB
        db_response = self.dynamodb.get_item(
            TableName=AWS_POST_TABLE_NAME,
            Key={'ID-post': {'S': photo_id}},
        )

        if 'Item' not in db_response:
            # Consider a non-existing task as a pending one,
            # as if the first Lambda did not execute yet
            return PhotoUploadResult(
                photo_id=photo_id,
                status='PENDING',
                timestamp=AwsPhotoDataSource._generate_timestamp(),
                author_username='',
            )

        # Return the actual result from the database
        db_item = db_response.get('Item')
        print(db_item['error'])
        return PhotoUploadResult(
            photo_id=photo_id,
            status=db_item['state']['S'].upper(),
            timestamp=db_item['ts']['S'],
            author_username=db_item['username']['S'],
            error_message=db_item['error']['S'] if 'S' in db_item['error'] else None,
        )

    @staticmethod
    def _generate_photo_id() -> str:
        return uuid.uuid4().hex

    @staticmethod
    def _generate_timestamp() -> str:
        return datetime.utcnow().replace(microsecond=0).isoformat()
