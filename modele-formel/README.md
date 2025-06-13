# Modèle Event-B pour le système de contrôle des feux tricolores

Ce dossier contient les spécifications formelles en Event-B pour le système de contrôle des feux tricolores. L'objectif est de modéliser mathématiquement le comportement du système et de vérifier ses propriétés de sécurité et de vivacité.

## Structure du modèle

- **TrafficLightContext.ctx** : Le contexte définissant les constantes du système
- **TrafficLightControl.mch** : La machine principale définissant les variables, invariants et événements

## Concept du modèle

Le modèle Event-B créé repose sur les concepts suivants :

1. **États et transitions** : Le système passe par différentes phases (Nord-Sud, Est-Ouest et transitions)
2. **Propriétés de sécurité** : Les invariants garantissent qu'il n'y aura jamais de conflits entre les feux
3. **Optimisation des temps d'attente** : Le modèle inclut des variables pour les files d'attente et les temps d'attente

## Propriétés de sécurité

Deux propriétés de sécurité essentielles sont formellement spécifiées et vérifiées :

1. **Absence de conflits** : Les directions perpendiculaires ne peuvent jamais avoir le feu vert simultanément
2. **Sécurité des piétons** : Les piétons ne peuvent traverser que lorsque les véhicules correspondants sont arrêtés

## Modèle mathématique pour l'optimisation

Le modèle inclut un événement `OptimizePhases` qui est une abstraction du processus d'optimisation des durées de phases. L'implémentation concrète utilisera un des algorithmes suivants :

### Webster's Method

L'algorithme de Webster calcule la durée optimale des cycles en fonction des flux de véhicules :

```
C_opt = (1.5 * L + 5) / (1 - Y)
```

Où :
- C_opt : Durée optimale du cycle
- L : Temps perdu total (transitions)
- Y : Somme des ratios de flux critique pour chaque phase

La durée de chaque phase est calculée proportionnellement au ratio de flux.

### Modèle adaptatif basé sur les files d'attente

La durée des phases est ajustée en fonction des longueurs des files :

```
duration_NS = min_duration + (max_duration - min_duration) * (q_NS / (q_NS + q_EW))
duration_EW = min_duration + (max_duration - min_duration) * (q_EW / (q_NS + q_EW))
```

Où :
- q_NS : Longueur totale des files Nord-Sud
- q_EW : Longueur totale des files Est-Ouest

## Intégration avec le code JavaScript

Pour intégrer ce modèle Event-B avec l'implémentation JavaScript existante, on peut :

1. Implémenter les algorithmes d'optimisation dans JavaScript
2. Utiliser les constantes définies dans le modèle formel
3. S'assurer que les invariants de sécurité sont respectés dans le code

## Vérification du modèle

Le modèle Event-B peut être vérifié avec des outils comme Rodin Platform pour s'assurer que :
- Les invariants sont maintenus par tous les événements
- Le système ne peut jamais atteindre un état dangereux
- Les propriétés de vivacité sont respectées (le système progresse)
