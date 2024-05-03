from typing import List
from dataclasses import dataclass


@dataclass
class User:
    username: str
    post_ids: List[str]
