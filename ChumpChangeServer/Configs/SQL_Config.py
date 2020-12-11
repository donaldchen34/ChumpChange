import os

# You need to replace the next values with the appropriate values for your configuration

basedir = os.path.abspath(os.path.dirname(__file__))
SQLALCHEMY_ECHO = False
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_DATABASE_URI = "postgresql://postgres:password123@localhost/ChumpChangeServer"

"""
In order to connect SQL to database:

app = Flask(__name__)
app.config.from_object('config')
db = SQLAlchemy(app)

"""