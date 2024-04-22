import pathlib
import time
from typing import Optional, List

from data_source.interface import IUserDataSource, IPhotoDataSource
from model import User, UserSummary, PhotoUploadResult


class MockUserDataSource(IUserDataSource):
    def __init__(self):
        self.users = [
            User(
                username='ciccio',
                post_ids=['aaa', 'bbb', 'ccc']
            ),
            User(
                username='ciccino',
                post_ids=['ddd', 'eee']
            ),
            User(
                username='mario',
                post_ids=['mmm', 'nnn']
            )
        ]

    def search_user(self, username: str) -> List[UserSummary]:
        return [
            UserSummary(username=user.username, posts_count=len(user.post_ids))
            for user in self.users
            if username in user.username
        ]

    def get_user_by_username(self, username: str) -> Optional[User]:
        try:
            return next(user for user in self.users if user.username == username)
        except StopIteration:
            return None

    def create_if_not_exists(self, username: str) -> None:
        pass


class MockPhotoDataSource(IPhotoDataSource):
    def __init__(self):
        pass

    def upload_photo(self, file: pathlib.Path) -> PhotoUploadResult:
        # Do a bit of fake processing for 500ms
        time.sleep(0.5)

        return PhotoUploadResult(photo_id='this-is-fake')
