# Rapport de Projet - Mini Stock Manager Flutter

## 1. Presentation du projet

Le projet consiste a developper une application mobile Android pour CFAO Motors CI, entreprise specialisee dans la distribution automobile et la gestion de pieces detachees. L'application doit remplacer la gestion papier du stock par une solution mobile connectee a une API Laravel securisee.

Le contexte se situe dans l'entrepot de Marcory, a Abidjan, ou les magasiniers suivent encore les stocks dans des cahiers. Cette methode rend difficile le suivi des quantites disponibles, des ventes, des ruptures et des responsabilites entre employes et administrateurs.

## 2. Objectifs

Les objectifs principaux sont :

- Permettre aux employes de consulter les pieces en stock.
- Permettre aux employes de signaler une vente.
- Permettre a l'administrateur de gerer les pieces.
- Permettre a l'administrateur de valider ou refuser les ventes.
- Mettre a jour le stock automatiquement apres validation.
- Conserver un suivi des actions importantes.
- Produire un APK Android installable.

## 3. Technologies utilisees

| Technologie       | Role                         |
| ----------------- | ---------------------------- |
| Flutter 3         | Developpement mobile Android |
| Dart              | Langage de programmation     |
| Provider          | Gestion d'etat               |
| HTTP              | Communication avec l'API     |
| SharedPreferences | Stockage local du token      |
| Laravel API       | Backend securise             |
| Laravel Sanctum   | Authentification par token   |
| Android APK       | Livrable mobile              |

## 4. Fonctionnement general

L'utilisateur se connecte avec son email et son mot de passe. L'API Laravel retourne un token qui est stocke localement avec SharedPreferences. Ce token est ensuite envoye dans les requetes protegees avec l'en-tete :

```text
Authorization: Bearer <token>
```

L'application adapte son interface selon le role :

- `employe` : consultation du stock et signalement des ventes.
- `admin` : gestion complete du stock et validation des ventes.

## 5. Fonctionnalites par role

### Employe

L'employe peut :

- voir la liste des pieces disponibles ;
- consulter le detail d'une piece ;
- signaler une vente ;
- suivre ses demandes de vente ;
- personnaliser son profil ;
- se deconnecter.

### Administrateur

L'administrateur peut :

- consulter le stock ;
- ajouter une piece ;
- modifier une piece ;
- supprimer une piece ;
- consulter les demandes de vente ;
- valider ou refuser une vente ;
- consulter les utilisateurs ;
- consulter les actions recentes ;
- suivre les alertes de stock faible.

## 6. Donnees gerees

Chaque piece contient :

- nom ;
- reference interne ;
- type de vehicule ;
- famille de piece ;
- quantite ;
- seuil d'alerte ;
- prix unitaire ;
- emplacement magasin ;
- description ;
- statut actif ou retire.

Les types de vehicules pris en charge sont :

- voiture ;
- moto ;
- velo ;
- camion ;
- autre.

Les familles de pieces sont :

- moteur ;
- freinage ;
- suspension ;
- electrique ;
- carrosserie ;
- pneu ;
- accessoire ;
- autre.

## 7. Workflow de vente

Le processus de vente est volontairement controle par l'administrateur :

1. L'employe consulte une piece.
2. Il clique sur `Signaler une vente`.
3. Il renseigne la quantite vendue, le client ou la reference, et une note.
4. La demande est envoyee a l'API.
5. L'administrateur voit la demande dans l'onglet `Ventes`.
6. Il valide ou refuse.
7. Si la vente est validee, la quantite disponible diminue automatiquement.
8. Si le stock atteint zero, la piece est retiree du catalogue.

Ce choix evite qu'un employe puisse retirer directement une piece du stock sans controle.

## 8. Architecture de l'application

L'application est organisee en couches :

- `models` : representation des donnees.
- `services` : appels HTTP vers l'API.
- `providers` : etat de l'application.
- `screens` : interfaces utilisateur.
- `widgets` : composants reutilisables.
- `config` : configuration API.

Cette separation rend le code plus lisible et facilite les evolutions futures.

## 9. Securite

La securite repose sur :

- authentification par token Laravel Sanctum ;
- stockage local du token ;
- routes protegees cote API ;
- role admin obligatoire pour creer, modifier, supprimer et valider les ventes ;
- separation des interfaces selon le role utilisateur.

## 10. Interface utilisateur

L'interface utilise une identite visuelle bleu et orange inspiree d'un outil professionnel de gestion :

- bleu pour la stabilite et la structure ;
- orange pour les actions, alertes et elements importants ;
- cartes de stock lisibles ;
- indicateurs de quantite et seuils ;
- navigation par onglets : Stock, Ventes, Profil, Admin.

## 11. Tests realises

Les tests suivants ont ete realises :

```text
flutter analyze
flutter test
php artisan test
flutter build apk --debug
```

Resultat :

```text
Analyse Flutter : OK
Tests Flutter   : OK
Tests Laravel   : OK
Build APK debug : OK
```

Un test fonctionnel API a ete realise :

```text
Connexion employe
Signalement d'une vente
Connexion admin
Validation de la vente
Verification de la diminution du stock
```

## 12. Limites

Certaines ameliorations peuvent encore etre ajoutees :

- recherche avancee par reference ;
- filtre par famille ou type de vehicule ;
- export PDF ou Excel ;
- historique complet par piece ;
- notifications push lors d'une demande de vente ;
- signature release officielle pour le Play Store ;
- gestion multi-entrepots.

## 13. Conclusion

Le projet repond au besoin initial de CFAO Motors CI : digitaliser la gestion du stock, reduire les erreurs du suivi papier et permettre une meilleure separation des responsabilites entre employes et administrateurs.

L'application permet maintenant de consulter le stock, signaler les ventes, valider les sorties et maintenir les quantites a jour en temps reel via une API securisee.
