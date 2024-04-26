from dataclasses import dataclass


@dataclass
class PhotoProcessingInvocation:
    photo_id: str  # UUID
    author_username: str
    bucket_name: str
    file_name: str

    def to_dict(self) -> dict:
        return {
            'username': self.author_username,
            's3': self.bucket_name,
            'idPhoto': self.photo_id,
            'keyPhoto': self.file_name,
        }
