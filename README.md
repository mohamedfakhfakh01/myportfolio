# MyPortfolio

[![CI](https://github.com/mohamedfakhfakh01/myportfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/mohamedfakhfakh01/myportfolio/actions/workflows/ci.yml)

Application mobile **Flutter** de portfolio étudiant, réalisée dans le cadre du module
*Développement Mobile*. Elle présente les portfolios de **deux étudiants** (binôme) — informations,
compétences et projets — avec **persistance locale** et intégration de l'**API GitHub**.

> 📘 Pour l'explication détaillée du code et la préparation à l'oral, voir **[`apprentissage.md`](apprentissage.md)**.

## Fonctionnalités

- Consulter les **deux portfolios** étudiants.
- Afficher les **informations**, **compétences** et **projets** de chaque étudiant.
- **Ajouter / modifier / supprimer** compétences et projets, et **éditer le profil** (CRUD complet).
- **Conserver les données** après fermeture de l'app (base locale SQLite).
- Afficher les **dépôts GitHub** publics d'un étudiant (API REST externe).
- Navigation fluide entre l'accueil et le profil.

## Stack technique

- **Flutter** 3.47.4 · **Dart** 3.13.3 (canal stable)
- `provider` — gestion de l'état
- `sqflite` + `path` — base de données locale SQLite
- `http` — appels à l'API REST GitHub
- `google_fonts` — typographie (Poppins)

## Prérequis

- **Flutter SDK** installé (`flutter --version`).
- **Pour iOS** : Xcode, **CocoaPods** (`brew install cocoapods` ou `sudo gem install cocoapods`), et
  soit un **simulateur iOS**, soit un **iPhone** en *Mode développeur* (signature configurée dans Xcode).
- **Pour Android** : Android Studio et un **émulateur** (AVD).

> ⚠️ Le chemin du projet ne doit **pas contenir d'espaces** (Flutter échoue sinon sur les builds natifs).

> 💡 Sur la machine de développement, Flutter n'est pas dans le `PATH` : utiliser
> `~/flutter/bin/flutter` à la place de `flutter`.

## Installation

Récupérer les dépendances :

```bash
flutter pub get
```

## Lancer l'application

Lister les appareils disponibles :

```bash
flutter devices
```

Lancer sur l'appareil par défaut :

```bash
flutter run
```

Ou cibler un appareil précis :

```bash
flutter run -d <device-id>
```

**Sur iPhone physique** : ouvrir `ios/Runner.xcworkspace` dans Xcode, onglet *Signing & Capabilities*,
choisir une *Team* (Apple ID), lancer une première fois depuis Xcode pour créer le certificat, puis
*faire confiance* au certificat sur l'iPhone (Réglages ▸ Général ▸ VPN et gestion de l'appareil).

## Tester l'intégration GitHub

Dans un profil, appuyer sur **✏️**, renseigner un **pseudo GitHub** public, puis enregistrer : la
section *Dépôts GitHub* charge les dépôts publics.
*(Connexion internet requise ; l'API publique est limitée à 60 requêtes/heure sans authentification.)*

## Vérifications et tests

Analyse statique (0 erreur attendu) :

```bash
flutter analyze
```

Tests :

```bash
flutter test
```

> Note : le test de widget vérifie que l'application démarre. Il ne touche pas la vraie base de
> données (sqflite nécessite un appareil ou un simulateur).

## Structure du projet (résumé)

```
lib/
├── main.dart              # Point d'entrée
├── app/                   # Widget racine + thème (couleurs, typographie)
├── core/database/         # Ouverture de la base SQLite + tables
├── shared/models/         # Modèles : Student, Skill, Project
└── features/
    ├── portfolio/         # Accueil, profil, état (Provider) et CRUD
    └── github/            # Intégration de l'API GitHub
```

## Limites connues / améliorations possibles

- Pas d'authentification (version 1).
- Les niveaux de compétence sont optionnels (non fournis pour tous les profils).
- L'affichage des dépôts GitHub nécessite une connexion internet ; avec un compte Apple gratuit, le
  profil de développement iOS expire après ~7 jours (relancer depuis Xcode pour le renouveler).
- Les informations de l'étudiant 1 peuvent être complétées directement dans l'application (CRUD).
