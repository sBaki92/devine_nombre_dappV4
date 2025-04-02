// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DevineNombreConfidentielAvecMise {
    address public joueurA;
    address public joueurB;

    bytes32 public hashSecret;
    bool public jeuEnCours = false;
    bool public nombreTrouve = false;

    uint public tentativeRestantes;
    uint public maxTentatives = 10;

    uint public derniereProposition;

    uint public miseA;
    uint public miseB;

    event NouvelleProposition(address joueur, uint proposition, string resultat);
    event NombreTrouve(uint nombre, address gagnant);
    event FinDuJeu(string raison);
    event NombreRevele(uint nombre, string salt);

    modifier seulementJoueurA() {
        require(msg.sender == joueurA, "Seul le joueur A peut faire cela.");
        _;
    }

    modifier seulementJoueurB() {
        require(msg.sender == joueurB, "Seul le joueur B peut faire cela.");
        _;
    }

    constructor() payable {
        joueurA = msg.sender;
        miseA = msg.value;
    }

    function initialiserJeu(bytes32 _hashSecret, address _joueurB) external seulementJoueurA {
        require(!jeuEnCours, "Un jeu est deja en cours.");
        require(miseA > 0, "La mise du joueur A est requise.");

        hashSecret = _hashSecret;
        joueurB = _joueurB;
        tentativeRestantes = maxTentatives;
        jeuEnCours = true;
        nombreTrouve = false;
    }

    function participerCommeJoueurB() external payable {
        require(msg.sender == joueurB, "Ce compte n'est pas autorise.");
        require(miseB == 0, "Le joueur B a deja mise.");
        require(msg.value > 0, "La mise du joueur B est requise.");
        miseB = msg.value;
    }

    function proposer(uint _proposition) external seulementJoueurB {
        require(jeuEnCours, "Aucun jeu en cours.");
        require(miseB > 0, "Vous devez d'abord miser.");
        require(tentativeRestantes > 0, "Aucune tentative restante.");
        require(!nombreTrouve, "Le nombre a deja ete trouve.");

        derniereProposition = _proposition;
        tentativeRestantes--;

        emit NouvelleProposition(msg.sender, _proposition, "Proposition enregistree");

        if (tentativeRestantes == 0) {
            jeuEnCours = false;
            payable(joueurA).transfer(address(this).balance);
            emit FinDuJeu("Tentatives epuisees. Le joueur B a perdu.");
        }
    }

    function reveler(uint _nombreSecret, string memory _salt) external seulementJoueurA {
        require(jeuEnCours, "Aucun jeu en cours.");
        require(!nombreTrouve, "Le nombre a deja ete trouve.");

        bytes32 hashCalcule = keccak256(abi.encodePacked(_nombreSecret, _salt));
        require(hashCalcule == hashSecret, "Le hash ne correspond pas.");

        if (_nombreSecret == derniereProposition) {
            nombreTrouve = true;
            jeuEnCours = false;
            payable(joueurB).transfer(address(this).balance);
            emit NombreTrouve(_nombreSecret, joueurB);
        } else {
            jeuEnCours = false;
            payable(joueurA).transfer(address(this).balance);
            emit FinDuJeu("La derniere proposition n'etait pas correcte. Joueur A gagne.");
        }

        emit NombreRevele(_nombreSecret, _salt);
    }

    function getSoldeContrat() external view returns (uint) {
        return address(this).balance;
    }
}
