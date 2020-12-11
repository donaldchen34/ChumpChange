import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from WebServer.plaid_server import plaid_api
from WebServer.database_routes import database_api


app = Flask(__name__)
app.register_blueprint(plaid_api, url_prefix = '/plaid')
app.register_blueprint(database_api, url_prefix = '/db')

app.config.from_object('Configs.SQL_Config')
from Database.Model import db

db.init_app(app)

@app.route('/')
def index():
    return "OK!"

if __name__ == '__main__':
#    app.run(debug=True)
    app.run(host = '0.0.0.0', port=os.getenv('PORT', 5555), debug=True)
