from dataclasses import dataclass


@dataclass
class UserSummary:
    username: str
    posts_count: int
