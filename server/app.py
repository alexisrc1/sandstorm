from flask import Flask
from flask import request, abort, jsonify

import os.path
import uuid
from datetime import datetime
from pathlib import Path
import itertools

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = Path() / 'static' / 'recordings'

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
    file = request.files['recording']
    if not file or file.filename == '':
        abort(505)
        return redirect(request.url)
    filename = f"{datetime.now().isoformat()}-{uuid.uuid4()}.m4a"
    path = app.config['UPLOAD_FOLDER'] / filename
    file.save(path.open('wb'))
    return jsonify(
        filename = filename    
    )


@app.route('/recordings')
def recordings():
    """Lists the existing recordings"""
    recordings = app.config['UPLOAD_FOLDER'].iterdir()
    top_recordings = itertools.islice(recordings, 1000)
    return jsonify(
        recordings = [
            {
                "name" : recording.name,
                "time": recording.stat().st_mtime_ns
            }
            for recording in top_recordings        
        ]
    )
