import pathlib
import re
from tempfile import NamedTemporaryFile
from typing import List

from flask import Flask, request, abort, Response, jsonify

from data_source import UserDataSource, PhotoDataSource
from model import UserSummary

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
def get_user_by_username(username: str) -> Response:
    found_user = users.get_user_by_username(username)
    if not found_user:
        abort(404)

    return jsonify(found_user)


@app.route('/photos', methods=['POST'])
def upload_new_photo() -> Response:
    # Handle missing "authentication" (just the username, very secure)
    if 'Authorization' not in request.headers:
        abort(401)

    username = request.headers.get('Authorization')
    # Handle invalid username
    valid_username_regex = re.compile(r'^[a-z0-9_]+$')
    if not valid_username_regex.match(username):
        abort(403)  # Forbidden?

    users.create_if_not_exists(username)

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
        upload_result = photos.upload_photo(pathlib.Path(tmp.name))
        return jsonify(upload_result)


if __name__ == '__main__':
    app.run()
