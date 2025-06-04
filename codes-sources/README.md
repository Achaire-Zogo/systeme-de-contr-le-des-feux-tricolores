# Système de Contrôle des Feux Tricolores

Ce projet est une simulation d'un système de contrôle des feux tricolores développé avec FastAPI et une interface web interactive.

## Fonctionnalités

- Simulation de plusieurs carrefours avec des feux tricolores
- Mode automatique avec cycle des feux configurables
- Mode manuel pour contrôler individuellement chaque feu
- Interface web interactive en temps réel avec WebSockets
- Visualisation des états des feux et des temps restants
- Configuration des durées pour chaque couleur de feu

## Prérequis

- Python 3.7+
- pip (gestionnaire de paquets Python)

## Installation

1. Clonez ce dépôt :
```bash
git clone https://github.com/Achaire-Zogo/systeme-de-controle-des-feux-tricolores.git
cd systeme-de-controle-des-feux-tricolores/codes-sources
```

2. Installez les dépendances :
```bash
pip install -r requirements.txt
```

## Utilisation

1. Démarrez l'application :
```bash
cd app
uvicorn main:app --reload
```

2. Ouvrez votre navigateur et accédez à :
```
http://localhost:8000
```

3. Utilisez l'interface pour :
   - Démarrer/arrêter le système
   - Basculer entre les modes automatique et manuel
   - Modifier les durées des feux
   - Contrôler manuellement les feux (en mode manuel)

## Structure du projet

```
codes-sources/
├── app/
│   └── main.py          # Application FastAPI principale
├── static/
│   └── style.css        # Styles CSS supplémentaires
├── templates/
│   └── index.html       # Interface utilisateur
└── requirements.txt     # Dépendances du projet
```

## Fonctionnement

- **Mode Automatique** : Les feux alternent automatiquement selon les durées configurées.
- **Mode Manuel** : Vous pouvez contrôler chaque feu individuellement.
- **WebSockets** : Les mises à jour sont envoyées en temps réel à tous les clients connectés.

## Personnalisation

Vous pouvez facilement ajouter plus de carrefours et de feux en modifiant le fichier `main.py` :

```python
# Ajouter un nouveau carrefour
nouveau_carrefour = Carrefour("c3", "Carrefour Tertiaire")
nouveau_carrefour.ajouter_feu(FeuTricolore("f5", "Nord-Sud"))
nouveau_carrefour.ajouter_feu(FeuTricolore("f6", "Est-Ouest"))
systeme.ajouter_carrefour(nouveau_carrefour)
```
