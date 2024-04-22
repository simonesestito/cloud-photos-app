import pathlib
from typing import List

from flask import Flask, request, abort

from model import User, UserSummary, PhotoUploadResult

from data_source import UserDataSource, PhotoDataSource

from tempfile import NamedTemporaryFile

app = Flask(__name__)
users = UserDataSource()
photos = PhotoDataSource()


@app.route('/users')
def search_users() -> List[UserSummary]:
    query_username = request.args.get('username', default='')
    if len(query_username) < 3:
        abort(400)

    return users.search_user(query_username)


@app.route('/users/<username>')
def get_user_by_username(username: str) -> User:
    found_user = users.get_user_by_username(username)
    if not found_user:
        abort(404)

    return found_user


@app.route('/photos', methods=['POST'])
def upload_new_photo() -> PhotoUploadResult:
    # Handle missing file part
    if 'photo' not in request.files:
        abort(400)

    photo = request.files['photo']
    # Handle missing selected file
    if photo.filename == '':
        abort(400)

    # Use a temporary file for processing
    with NamedTemporaryFile() as tmp:
        photo.save(tmp.name)
        return photos.upload_photo(pathlib.Path(tmp.name))


if __name__ == '__main__':
    app.run()
