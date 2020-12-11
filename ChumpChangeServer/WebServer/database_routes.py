from flask import request
from flask import jsonify
from .plaid_server import pretty_print_response
from flask import Blueprint
from sqlalchemy.orm import sessionmaker

import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir)

from Database.Model import db, User

database_api = Blueprint('database_api', __name__)

@database_api.route('/show_accounts', methods = ['GET'])
def show_Accounts():

    accounts = {}

    if request.method == "GET":
        for account in db.session.query(User):
            accounts[account.username] = account.password

    pretty_print_response(accounts)
    return jsonify(accounts)

#Create account: Accepts { 'username' : username, 'password' : password }
#Returns { 'responss' : x }
# x = 0 -> Username taken, x = 1 -> Account Successfully Created
# x = 2 -> Data not in JSON format
@database_api.route('/create_account', methods = ['POST'])
def add_Account():

    response = {}

    if request.method == "POST":
        if request.is_json:
            info = request.get_json()
            username = info['username']
            password = info['password']
            #id = info['id']

            user = User.query.filter_by(username=username).first()
            if user:
                print("Username is already in use. Please choose another.")
                response['response'] = 0
            else:
                user = User(username = username, password = password)
                db.session.add(user)
                db.session.commit()
                response['response'] = 1

        else:
            response['response'] = 2

    pretty_print_response(response)
    return jsonify(response)

#Checks login: Accepts { 'username' : username, 'password' : password }
#Returns { 'response' : x}, x = 0 -> Incorrect user or password, x = 1 -> Valid login
# x = 2 -> Data not in JSON format
@database_api.route('/login',methods = ['POST'])
def check_Login():

    valid = {}

    if request.method == "POST":
        if request.is_json:
            info = request.get_json()
            username = info['username']
            password = info['password']

            user = User.query.filter_by(username=username).first()
            if user:
                if user.password == password:
                    valid['response'] = 1
                else:
                    valid['response'] = 0
            else:
                valid['response'] = 0

        else:
            valid['response'] = 2

    pretty_print_response(valid)
    return jsonify(valid)

