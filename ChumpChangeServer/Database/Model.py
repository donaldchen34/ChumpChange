from flask_sqlalchemy import SQLAlchemy



db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'accounts'
    #id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, primary_key=True)
    password = db.Column(db.String(120), unique=False, nullable=False)
    #email = db.Column(db.String(120), unique=True, nullable=False)

    def __repr__(self):
        return "{'username':'%s' , 'password':'%s'}" % (self.username, self.password)

class AccessToken(db.Model):
    #Add expiration dates
    #Connect Tables
    __table__name = 'access_token'
    id = db.Column(db.String(131), primary_key = True)
    username = db.Column(db.String(80), unique = False,nullable = False)
    access_token = db.Column(db.String(51), unique = False, nullable = False)

    def __repr__(self):
        return "{'username':'%s' , 'access token':'%s'}" % (self.username, self.access_token)