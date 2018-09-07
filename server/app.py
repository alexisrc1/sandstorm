import itertools
import json
from pathlib import Path

from flask import Flask, request, jsonify, Response
from werkzeug.exceptions import HTTPException, BadRequest, UnsupportedMediaType

from database import db, Recording

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 8 * 1024 * 1024  # 8Mib
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

with app.app_context():
    db.create_all()

UPLOAD_FOLDER = Path() / 'static' / 'recordings'
if not UPLOAD_FOLDER.exists():
    UPLOAD_FOLDER.mkdir(parents=True)


@app.route("/")
def hello():
    return '''
        <!doctype html>
        <title>Upload new File</title>
        <h1>Upload new File</h1>
        <form method=post enctype=multipart/form-data action=upload>
          <input type=file name=recording>
          <input type=submit value=Upload>
        </form>
        '''


@app.route('/upload', methods=['POST'])
def upload():
    """Upload a file to the server"""

    if 'recording' not in request.files:
        raise BadRequest('Missing recording file')
    file = request.files['recording']

    if not file or file.filename == '':
        raise BadRequest('Missing recording filename')

    if not file.filename.endswith('m4a') or file.mimetype != 'audio/mp4':
        raise UnsupportedMediaType('The recording is not an m4a file')

    recording = Recording.create()
    path = UPLOAD_FOLDER / recording.name
    with path.open('wb') as destination_file:
        file.save(destination_file)

    return jsonify(recording.toDict())


def recording_json(recording):
    return json.dumps({
        "name": recording.name,
        "time": recording.stat().st_mtime_ns
    }) + "\n"


@app.route('/recordings')
def recordings():
    """Lists the existing recordings"""
    recordings_iter = UPLOAD_FOLDER.iterdir()
    top_recordings = itertools.islice(recordings_iter, 1000)
    return Response(
        map(recording_json, top_recordings),
        mimetype='text/json'
    )


@app.errorhandler(HTTPException)
def exception_handler(error):
    return jsonify(
        error=error.description,
        code=error.code
    ), error.code


app.run(host='0.0.0.0')
