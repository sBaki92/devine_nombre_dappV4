from web3 import Web3
import json
import os
from dotenv import load_dotenv

load_dotenv()
os.environ["CONTRACT_ADDRESS"] = os.getenv("CONTRACT_ADDRESS").split("#")[0].strip()

# Connexion à Ankr Sepolia
w3 = Web3(Web3.HTTPProvider(os.getenv("ANKR_URL")))
assert w3.is_connected(), "Erreur de connexion Web3"

pk_a = os.getenv("PRIVATE_KEY_JOUEUR_A")
print(f"[DEBUG] Clé A : {pk_a} (len={len(pk_a)})")


# Charger le contrat
with open("DevineNombreABI.json") as f:
    abi = json.load(f)

raw_address = os.getenv("CONTRACT_ADDRESS")
print(f"[DEBUG] Adresse lue du .env : '{raw_address}' (longueur = {len(raw_address)})")
contract = w3.eth.contract(address=os.getenv("CONTRACT_ADDRESS"), abi=abi)

# Comptes
joueurA = w3.eth.account.from_key(os.getenv("PRIVATE_KEY_JOUEUR_A"))
joueurB = w3.eth.account.from_key(os.getenv("PRIVATE_KEY_JOUEUR_B"))
