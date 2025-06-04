#!/bin/bash
# Script pour démarrer le système de contrôle des feux tricolores
echo "Démarrage du système de contrôle des feux tricolores..."
# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "Python3 n'est pas installé. Veuillez l'installer avant de continuer."
    exit 1
fi
# Vérifier si pip est installé
if ! command -v pip &> /dev/null; then
    echo "pip n'est pas installé. Veuillez l'installer avant de continuer."
    exit 1
fi

# Installer les dépendances si nécessaire
echo "Installation des dépendances..."
pip install -r requirements.txt

# Démarrer l'application
echo "Démarrage du serveur FastAPI..."
cd $(dirname "$0")
cd app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
