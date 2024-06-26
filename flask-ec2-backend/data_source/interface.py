import pathlib
from abc import ABC, abstractmethod
from typing import List, Optional

from model import PhotoUploadResult, User, UserSummary


class IUserDataSource(ABC):
    @abstractmethod
    def search_user(self, username: str) -> List[UserSummary]:
        pass

    @abstractmethod
    def get_user_by_username(self, username: str) -> Optional[User]:
        pass


class IPhotoDataSource(ABC):
    @abstractmethod
    def upload_photo(self, username: str, file: pathlib.Path) -> PhotoUploadResult:
        pass

    @abstractmethod
    def get_photo_upload(self, photo_id: str) -> PhotoUploadResult:
        pass
