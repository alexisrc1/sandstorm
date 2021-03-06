import uuid
from datetime import datetime

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Recording(db.Model):
    name = db.Column(
        db.String(120),
        primary_key=True)
    timestamp = db.Column(
        db.Integer,
        nullable=False,
        comment="Creation time in milliseconds since epoch")

    def __repr__(self):
        return f'<Recording {self.name}>'

    def to_dict(self):
        return {
            "name": self.name,
            "timestamp": self.timestamp
        }

    @staticmethod
    def create():
        """Create a new recording with the current timestamp and a random name"""
        now = datetime.now()
        filename = f"{now.isoformat()}-{uuid.uuid4()}.m4a"
        return Recording(name=filename, timestamp=int(now.timestamp() * 1000))
