from dataclasses import dataclass
from typing import Optional


@dataclass
class PhotoUploadResult:
    photo_id: str
    status: str  # PENDING, ERROR, SUCCESS
    timestamp: str  # ISO Timestamp
    author_username: str
    error_message: Optional[str]
