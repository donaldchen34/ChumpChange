import os

basedir = os.path.abspath(os.path.dirname(__file__))

PLAID_CLIENT_ID = ''
PLAID_SECRET_SAND = '' #Sandbox
PLAID_SECRET_DVLP = '' #Development
PLAID_PUBLIC_KEY = ''

PLAID_ENV = 'sandbox'

PLAID_PRODUCTS = ['auth', 'transactions']
PLAID_COUNTRY_CODES = ['US','CA','GB','FR','ES']


PLAID_OAUTH_REDIRECT_URI = os.getenv('PLAID_OAUTH_REDIRECT_URI', '');
PLAID_OAUTH_NONCE = os.getenv('PLAID_OAUTH_NONCE', '');

configs = {
  'user': {
      'client_user_id': PLAID_CLIENT_ID,
  },
  'products': PLAID_PRODUCTS,
  'client_name': "Plaid Test App",
  'country_codes': PLAID_COUNTRY_CODES,
  'language': 'en',
  'webhook': 'https://sample-webhook-uri.com',
  'link_customization_name': 'default',
  'account_filters': {
      'depository': {
          'account_subtypes': ['checking', 'savings'],
      },
  },
}
