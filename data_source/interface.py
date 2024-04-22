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

    @abstractmethod
    def create_if_not_exists(self, username: str) -> None:
        pass


class IPhotoDataSource(ABC):
    @abstractmethod
    def upload_photo(self, file: pathlib.Path) -> PhotoUploadResult:
        pass
