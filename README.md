# Mini Stock Manager Flutter - CFAO Motors CI

Application mobile Android de gestion de stock pour **CFAO Motors CI** a Marcory, Abidjan. Elle est connectee a une API Laravel securisee et permet de digitaliser la consultation, le suivi et la gestion des pieces automobiles en temps reel.

## Scenario

CFAO Motors CI gere des centaines de pieces detachees dans son entrepot de Marcory. Les magasiniers utilisent encore des cahiers papier pour suivre les entrees, les ventes et les niveaux de stock. Cette methode provoque des erreurs, des pertes et des retards.

Le responsable IT demande une application Android connectee a l'API Laravel securisee du Projet 4. L'objectif est de donner aux employes un outil simple pour consulter le stock et signaler les ventes, tout en laissant aux administrateurs la responsabilite de valider les sorties et de gerer les pieces.

## Fonctionnalites

### Employe connecte

- Connexion securisee avec email et mot de passe.
- Consultation de la liste des pieces en stock.
- Consultation de la fiche detaillee d'une piece.
- Signalement d'une vente a l'administrateur.
- Suivi de ses demandes de vente.
- Personnalisation de son espace utilisateur.
- Deconnexion.

### Administrateur connecte

- Toutes les fonctionnalites de l'employe.
- Ajout d'une nouvelle piece.
- Modification d'une piece existante.
- Suppression d'une piece.
- Gestion des quantites, seuils d'alerte, prix et emplacements.
- Validation ou refus des ventes signalees par les employes.
- Mise a jour automatique du stock apres validation d'une vente.
- Consultation des utilisateurs, administrateurs et activites recentes.

## Gestion du stock

Chaque piece contient les informations suivantes :

- Nom de la piece.
- Reference interne.
- Type de vehicule : voiture, moto, velo, camion ou autre.
- Famille : moteur, freinage, suspension, electrique, carrosserie, pneu, accessoire ou autre.
- Quantite disponible.
- Seuil d'alerte.
- Prix unitaire.
- Emplacement en magasin.
- Description.
- Statut visible ou retire du catalogue.

## Workflow de vente

1. L'employe ouvre la fiche d'une piece.
2. Il signale une vente en renseignant la quantite, le client ou la reference de vente, et une note optionnelle.
3. La demande apparait dans l'espace admin.
4. L'administrateur valide ou refuse la demande.
5. Si la demande est validee, le stock est diminue automatiquement.
6. Si la quantite tombe a zero, la piece est retiree du catalogue.

## Stack technique

- Flutter 3
- Dart
- Provider pour la gestion d'etat
- HTTP pour la communication avec l'API
- SharedPreferences pour stocker le token localement
- Laravel API avec Sanctum
- Android APK comme livrable mobile

## Architecture Flutter

```text
lib/
  config/
    api_config.dart
  models/
    product.dart
    user.dart
    sale_request.dart
    activity_log.dart
  providers/
    auth_provider.dart
    product_provider.dart
    sale_request_provider.dart
    admin_provider.dart
  screens/
    login_screen.dart
    dashboard_screen.dart
    product_list_screen.dart
    product_detail_screen.dart
    product_form_screen.dart
    sale_request_form_screen.dart
    sale_requests_screen.dart
    admin_dashboard_screen.dart
    profile_screen.dart
  services/
    auth_service.dart
    product_service.dart
    sale_request_service.dart
    admin_service.dart
  widgets/
    custom_button.dart
    product_card.dart
```

## API utilisee

L'application consomme les endpoints principaux suivants :

```text
POST   /api/login
POST   /api/logout
GET    /api/profil
PUT    /api/profil
GET    /api/produits
POST   /api/produits
PUT    /api/produits/{id}
DELETE /api/produits/{id}
GET    /api/sale-requests
POST   /api/sale-requests
POST   /api/sale-requests/{id}/approve
POST   /api/sale-requests/{id}/reject
GET    /api/admin/users
GET    /api/admin/activities
POST   /api/activities
```

## Configuration API

L'URL de l'API est definie dans :

```text
lib/config/api_config.dart
```

Configuration actuelle pour un telephone physique sur le meme reseau que le PC :

```dart
static const String baseUrl = 'http://10.85.182.104:8001/api';
```

Pour lancer Laravel sur le reseau :

```bash
php artisan serve --host=0.0.0.0 --port=8001
```

Pour un emulateur Android, remplacer l'adresse par :

```dart
static const String baseUrl = 'http://10.0.2.2:8001/api';
```

## Comptes de test

```text
Administrateur : admin@cfao.ci / password123
Employe        : magasinier@cfao.ci / password123
```

## Installation

Installer les dependances Flutter :

```bash
flutter pub get
```

Lancer l'application :

```bash
flutter run
```

Analyser le code :

```bash
flutter analyze
```

Executer les tests :

```bash
flutter test
```

Generer un APK de debug :

```bash
flutter build apk --debug
```

Generer un APK release :

```bash
flutter build apk --release
```

APK genere :

```text
build/app/outputs/flutter-apk/app-release.apk
```

Note importante :

L'APK genere n'est pas destine a etre utilise comme une application de production autonome pour le moment. Le backend Laravel n'est pas heberge sur un serveur public ; il fonctionne en local sur le reseau du developpeur. L'APK sert donc principalement de preuve de savoir-faire et de livrable demonstratif pour montrer que l'application Android peut etre installee, lancee et connectee a l'API lorsque le backend est disponible.

## Tests effectues

Les verifications suivantes ont ete effectuees :

```text
flutter analyze : OK
flutter test    : OK
php artisan test: OK
flutter build apk --debug : OK
```

Un test API reel a aussi ete effectue :

```text
Connexion employe CFAO
Signalement d'une vente
Connexion admin CFAO
Validation de la vente
Diminution automatique du stock
```

## Livrables

- Code source Flutter.
- API Laravel du Projet 4 adaptee au stock.
- APK Android installable.
- Captures de l'application fonctionnelle.
- README professionnel.
- Rapport de projet : `RAPPORT_PROJET.md`.

## Auteur

AKPA SALOMON OWESS
Projet realise dans le cadre du **Projet 5 - Mini Stock Manager Flutter** .
