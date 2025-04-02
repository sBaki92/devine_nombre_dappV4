from flask import Flask, render_template, request, redirect
from web3_provider import w3, contract, joueurA, joueurB
import time

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    message = ""
    if request.method == "POST":
        action = request.form["action"]

        if action == "initialiser":
            hash_secret = request.form["hash_secret"]
            joueurB_addr = joueurB.address
            tx = contract.functions.initialiserJeu(hash_secret, joueurB_addr).build_transaction({
                "from": joueurA.address,
                "nonce": w3.eth.get_transaction_count(joueurA.address),
                "gas": 300000,
                "gasPrice": w3.to_wei("10", "gwei")
            })
            signed = joueurA.sign_transaction(tx)
            tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
            w3.eth.wait_for_transaction_receipt(tx_hash)
            message = "Jeu initialisé !"

        elif action == "reveler":
            number = int(request.form["nombre"])
            salt = request.form["salt"]
            tx = contract.functions.reveler(number, salt).build_transaction({
                "from": joueurA.address,
                "nonce": w3.eth.get_transaction_count(joueurA.address),
                "gas": 300000,
                "gasPrice": w3.to_wei("10", "gwei")
            })
            signed = joueurA.sign_transaction(tx)
            tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
            w3.eth.wait_for_transaction_receipt(tx_hash)
            message = "Révélation envoyée !"

    return render_template("index.html", message=message)
