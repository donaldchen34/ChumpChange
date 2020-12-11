import plaid
import json
from flask import request
from flask import jsonify
from Configs.Plaid_Config import configs, PLAID_CLIENT_ID, PLAID_SECRET_SAND, PLAID_SECRET_DVLP, PLAID_ENV, PLAID_PUBLIC_KEY
from flask import Blueprint
import datetime
from datetime import date, timedelta

from Database.Model import db, AccessToken

plaid_api = Blueprint('plaid_api', __name__)


client = plaid.Client(client_id = PLAID_CLIENT_ID, secret=PLAID_SECRET_SAND,
                      #public_key = PLAID_PUBLIC_KEY ,
                      environment=PLAID_ENV, api_version='2019-05-29')

link_token = None
payment_id = None

#GET - Retrive item
#POST - Add a new item
#PUT - Update an item
#Delete - Delete an item

@plaid_api.route('/get_link_token',methods = ['GET'])
def get_Link_Token():
    global link_token
# Response is {'expiration': '', 'link_token': 'link-development-xxxx', 'request_id': ''}
    response = client.LinkToken.create(configs)

    link_token = response['link_token']
    return  jsonify(response)


@plaid_api.route('/post_access_token',methods = ['GET','POST'])
def get_Access_Token():

    public_token = None
    username = None

    if request.method == "POST":
        if request.is_json:
            data = request.get_json()
            public_token = data['public_token']
            username = data['username']

        if not request.is_json:
            notJsonData = request.get_data()
            public_token,username = getPublicToken(notJsonData)


    try:
        exchange_response = client.Item.public_token.exchange(public_token)
    except plaid.errors.PlaidError as e:
        return jsonify(format_error(e))

    pretty_print_response(exchange_response)
    access_token = exchange_response['access_token']
    saveAccessToken(access_token,username)

    return jsonify(exchange_response)


@plaid_api.route('/get_banks', methods = ['GET','POST'])
def get_Banks(bank = None):
    response = {'accounts' : []}

    if request.method == "POST":
        if request.is_json:
            data = request.get_json()
            username = data['username']
            accessTokens = AccessToken.query.filter_by(username=username).all()
            for accessToken in accessTokens:
                access_token = accessToken.access_token
                #Grab bank
                item_response = client.Item.get(access_token)
                institution_response = client.Institutions.get_by_id(item_response['item']['institution_id'],['US'])
                bank = institution_response['institution']['name']
                #response['bank'] = bank #delete? - might be buggy with more than one bank
                #Grab balance
                balance_response = client.Accounts.balance.get(access_token)
                pretty_print_response(balance_response)
                for account in balance_response['accounts']:
                    info = {
                            "account_id" : account['account_id'],
                            "balance" : account['balances']['available'],
                            "current" : account['balances']['current'],
                            "name" : account['name']
                            }

                    response['accounts'].append(info)


    pretty_print_response(response)
    return jsonify(response)

#Default date dates back to one month ago
@plaid_api.route('/get_activity',methods = ['GET','POST'])
def get_Activity(bank = None,startDate = str(date.today() - timedelta(days = 30)), endDate = str(date.today())):
    response = {'activity': []}

    if request.method == "POST":
        if request.is_json:
            data = request.get_json()
            username = data['username']
            accessTokens = AccessToken.query.filter_by(username=username).all()
            for accessToken in accessTokens:
                access_token = accessToken.access_token
                #Grab bank
                item_response = client.Transactions.get(access_token,start_date=startDate,end_date=endDate)
                bank_name = item_response['accounts'][2]['name']
                for transaction in item_response['transactions']:
                    info = {
                            "account_id" : transaction['account_id'],
                            "bank_name" : bank_name,
                            "amount" : transaction['amount'],
                            "category" : transaction['category'],
                            "date" : transaction['date'],
                            "store_name" : transaction['name'],
                            "location" : transaction['location']
                            }

                    response['activity'].append(info)


    pretty_print_response(response)
    return jsonify(response)


testData = None
notJsonData = None
publicToken = None

@plaid_api.route('/test', methods = ['GET','POST'])
def testFunc():
    if request.method == "POST":
        if request.is_json:
            data = request.get_json()
            access_token = data['access_token']
            username = data['username']

            saveAccessToken(access_token, username)



    return jsonify(testData)


#Removes the extra "b_ " from the output
def getPublicToken(nonJsondata):
    #print(nonJsondata) // Testing
    data = str(nonJsondata)
    reformData = data[2:-1]
    jsonData = json.loads(reformData)

    return(jsonData['public_token'], jsonData['username'])

def saveAccessToken(access_Token, username):

    key = username + access_Token
    accessToken = AccessToken.query.filter_by(id=key).first()
    if not accessToken:
        newAccessToken = AccessToken(username=username, access_token = access_Token, id = key)
        db.session.add(newAccessToken)
        db.session.commit()

    pass

def pretty_print_response(response):
  print(json.dumps(response, indent=2, sort_keys=True))

def format_error(e):
  return {'error': {'display_message': e.display_message, 'error_code': e.code, 'error_type': e.type, 'error_message': e.message } }


