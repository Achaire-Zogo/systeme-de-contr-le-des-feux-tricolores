# Système de Contrôle des Feux Tricolores avec Théorie des Files d'Attente

Ce projet implémente un système de simulation et de contrôle des feux tricolores en utilisant la théorie des files d'attente pour modéliser les flux de véhicules et de piétons aux carrefours.

## Caractéristiques Principales

- **Modélisation mathématique** : Application de la théorie des files d'attente pour représenter le trafic aux carrefours
- **Visualisation en temps réel** : Interface interactive montrant les files d'attente des véhicules et des piétons
- **Animation des traversées** : Visualisation du passage des véhicules et des piétons lors des changements de feu
- **Statistiques** : Calcul des temps d'attente moyens basé sur le théorème de Little

## Structure du Projet

- **`/codes-sources`** : Code source de l'application
- **`/Documentations`** : Documentation technique du projet
- **`/presentation`** : Présentation LaTeX Beamer expliquant le modèle mathématique

## Technologies Utilisées

- **Backend** : FastAPI (Python), utilisant asyncio pour les opérations asynchrones
- **Frontend** : HTML/CSS/JavaScript avec communication WebSocket
- **Modèles Mathématiques** : Implémentation de la distribution de Poisson pour les arrivées

Voir le README dans le dossier `/codes-sources` pour les instructions d'installation et d'utilisation.
