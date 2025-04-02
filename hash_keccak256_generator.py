from web3 import Web3

w3 = Web3()

number = 42
salt = "abc123"

number_bytes = number.to_bytes(32, 'big')
salt_bytes = salt.encode('utf-8')

hash_secret = w3.keccak(number_bytes + salt_bytes).hex()

print("hash à utiliser dans initialiserJeu :", hash_secret)
