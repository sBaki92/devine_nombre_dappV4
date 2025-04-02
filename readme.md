# Devine Nombre DApp – Jeu Ethereum avec Confidentialité et Mises

## Objectif

Cette DApp implémente un jeu de type **"Devine le nombre"** sur la blockchain Ethereum (testnet Sepolia), avec :

- **Confidentialité du nombre** via un engagement cryptographique (`commit`)
- **Révélation (`reveal`) contrôlée** et vérifiable publiquement
- **Gestion de mises en ETH** (joueur gagnant remporte la totalité des fonds)

Elle est composée :
- d’un **smart contract Solidity**
- d’une interface backend **Python + Flask**
- d’une couche d’interaction **Web3.py** connectée via **Ankr**

---

## Fonctionnement du Smart Contract

### Phase 1 – Engagement cryptographique (`commit`)

Le joueur A choisit :
- un **nombre secret** `x`
- un **sel** `salt` (chaîne aléatoire)

Il calcule :

```solidity
hash = keccak256(abi.encodePacked(x, salt));
```

et appelle :

```solidity
initialiserJeu(bytes32 hash, address joueurB)
```

Ce mécanisme assure que :

- le nombre reste invisible sur la blockchain
- l’engagement est non falsifiable (collision-résistant)
- la révélation ultérieure est vérifiable par quiconque

---

### Phase 2 – Déroulement du jeu

Le contrat utilise une double mise en ETH (joueur A et joueur B).

Le joueur B appelle :

```solidity
participerCommeJoueurB() payable
```

Puis il appelle :

```solidity
proposer(uint proposition)
```

Chaque proposition :

- décrémente un compteur de tentatives (`tentativeRestantes`)
- enregistre la dernière proposition

---

### Phase 3 – Révélation (reveal)

Le joueur A appelle :

```solidity
reveler(uint x, string salt)
```

Le contrat vérifie :

```solidity
keccak256(abi.encodePacked(x, salt)) == hashSecret
```

Si c’est vrai et que `x == derniereProposition`, le joueur B gagne.

Sinon, le joueur A récupère la totalité des fonds.

---

## Gestion des mises

- Les mises sont stockées via `msg.value` à la création du contrat (joueur A) et dans `participerCommeJoueurB()` (joueur B)
- Le solde cumulé est versé au gagnant unique, sans fractionnement.
- En cas d’échec (tentatives épuisées ou mauvais reveal), A récupère la totalité.

---

## Sécurité & bonnes pratiques

- Engagement `commit` irréversible
- `modifier` pour restreindre les appels (`seulementJoueurA`, `seulementJoueurB`)
- `require()` sur :
  - `msg.sender`
  - nombre de tentatives
  - état du jeu (`jeuEnCours`, `nombreTrouve`)
- Vérification du hash dans `reveler()` empêche toute triche

⚠️ Pas de gestion de timeout ou annulation automatique si un joueur abandonne : amélioration possible.

---

## Architecture DApp (Python)

- **Flask (`app.py`)** : expose une interface web simple (formulaires HTML)
- **Web3.py (`web3_provider.py`)** : gère la connexion à Sepolia via Ankr, construction et signature des transactions (`build_transaction + sign_transaction`)
- **Fichier `.env`** : stocke clés privées, adresse du contrat, endpoint RPC

## Exemple d’engagement (Python)

```python
from web3 import Web3

x = 42
salt = "abc123"

x_bytes = x.to_bytes(32, 'big')
salt_bytes = salt.encode("utf-8")
hash = Web3().keccak(x_bytes + salt_bytes).hex()
```

---

## 📂 Structure du projet

```bash
devine_nombre_dapp/
├── app.py                      # Flask web app
├── web3_provider.py            # Web3.py logic + contract loading
├── DevineNombreABI.json        # ABI from Remix
├── templates/
│   └── index.html              # Web interface
├── .env                        # Clés privées, RPC, etc.
└── README.md                   # Ce fichier
```
