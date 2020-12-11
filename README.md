# ChumpChange
IOS App that uses Plaid API to get bank accounts and their transactions

ChumpChange uses a webserver to connect to the Plaid Api and its database.
The database stores login information and access_tokens created by the the Plaid Api.

After logging in, the app gets all access_tokens associated with its user and with that, it grabs the bank accounts and their transactions
