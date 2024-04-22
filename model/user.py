from typing import List


class User:
    def __init__(self, username: str, post_ids: List[str]) -> None:
        self.username = username
        self.post_ids = post_ids
