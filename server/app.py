import itertools
import json
from pathlib import Path

from flask import Flask, request, jsonify, Response
from werkzeug.exceptions import HTTPException, BadRequest, UnsupportedMediaType

from database import db, Recording, Commenting

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
        <form method=post enctype=multipart/form-data action="upload_comments">
          <input type=text name=comment>
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

    db.session.add(recording)
    db.session.commit()
    return jsonify(recording.to_dict())


@app.route('/recordings')
def recordings():
    """Lists the existing recordings"""
    top_recordings = Recording.query.order_by(Recording.timestamp.desc()).limit(1000).all()
    recordings_iter = (json.dumps(r.to_dict()) + '\n' for r in top_recordings)
    return Response(
        recordings_iter,
        mimetype='text/plain')


@app.errorhandler(HTTPException)
def exception_handler(error):
    return jsonify(
        error=error.description,
        code=error.code
    ), error.code

#### comments


@app.route('/upload_comments', methods=['POST'])
def upload_comments():
    """Upload a comment to the server"""

    if 'comment' not in request.form:
        raise BadRequest('Missing comment')
    file = request.form['comment']

    if not file or file.filename == '':
        raise BadRequest('Missing comment filename')

    if not file.filename.endswith('txt'):
        raise UnsupportedMediaType('The comment is not a txt file')

    commenting = Commenting.create()
    path = UPLOAD_FOLDER / commenting.name
    with path.open('wb') as destination_file:
        file.save(destination_file)



    db.session.add(commenting)
    db.session.commit()
    return jsonify(commenting.to_dict())



app.run(host='127.0.0.1',debug=True, use_evalex=False)
