from collections import defaultdict
from typing import Optional, List

from data_source.interface import IUserDataSource
from model import User, UserSummary

import boto3
from mypy_boto3_dynamodb import DynamoDBClient


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
