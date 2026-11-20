# MyPortfolio

[![CI](https://github.com/mohamedfakhfakh01/myportfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/mohamedfakhfakh01/myportfolio/actions/workflows/ci.yml)

Application mobile **Flutter** de portfolio étudiant, réalisée dans le cadre du module
*Développement Mobile*. Elle permet de créer et consulter plusieurs portfolios — profil,
compétences, projets, parcours et contact — avec **persistance locale**, **export PDF** et
intégration de l'**API GitHub**.

> 📘 Pour l'explication détaillée du code et la préparation à l'oral, voir **[`apprentissage.md`](apprentissage.md)**.

## Fonctionnalités

**Consultation**
- Liste des portfolios avec **recherche** par nom ou filière.
- **Tableau de bord** du profil : salutation, **complétion du profil** (score calculé sur
  11 critères réellement remplis, avec le détail de ce qui manque), compteurs et actions rapides.
- **Compétences** groupées par catégorie, avec barre de niveau en dégradé.
- **Projets** : image, description, **technologies**, lien cliquable, **écran détail** dédié et
  **filtre par technologie**.
- **Parcours** : expériences et formations.
- **Contact** cliquable (e-mail, téléphone, LinkedIn, localisation).
- **Dépôts GitHub** publics de l'étudiant (API REST externe).

**Édition**
- **Créer, modifier, supprimer** un portfolio, ses compétences, projets et entrées de parcours.
- **Photo de profil** et **capture d'écran** par projet (galerie ou appareil photo).

**Sortie**
- **Export PDF** du portfolio (partage iOS) : profil, coordonnées cliquables, compétences, projets,
  expérience et formation.

**Confort**
- Thème **clair** (par défaut) ou **sombre**, mémorisé entre les lancements.
- Interface en **français** et en **anglais**.

## Stack technique

- **Flutter** 3.47.4 · **Dart** 3.13.3 (canal stable) · Material 3
- `provider` — gestion de l'état
- `sqflite` + `path` — base de données locale SQLite (schéma versionné, **v7**)
- `http` — appels à l'API REST GitHub
- `google_fonts` — typographie (**Plus Jakarta Sans** pour les titres, **Inter** pour le corps)
- `pdf` + `printing` — génération et partage du PDF
- `image_picker` + `path_provider` — photos et stockage local
- `url_launcher` — ouverture des liens (mailto, tel, web)

## Prérequis

- **Flutter SDK** installé (`flutter --version`).
- **Pour iOS** : Xcode (les bibliothèques passent par **Swift Package Manager**, intégré : pas de
  CocoaPods à installer), et soit un **simulateur iOS**,
  soit un **iPhone** en *Mode développeur* (signature configurée dans Xcode).
- **Android** : hors cible (l'app est faite pour l'iPhone) ; le dossier `android/` est conservé et
  compile, mais n'est ni testé ni maintenu.

> ⚠️ Le chemin du projet ne doit **pas contenir d'espaces** (Flutter échoue sinon sur les builds natifs).

> 💡 Sur la machine de développement, Flutter n'est pas dans le `PATH` : utiliser
> `~/flutter/bin/flutter` à la place de `flutter`.


## Installation

```bash
flutter pub get
```

## Lancer l'application

```bash
flutter devices          # lister les appareils
flutter run              # appareil par défaut
flutter run -d <device-id>
```

Construire l'APK Android :

```bash
flutter build apk --release                 # APK unique (~60 Mo, toutes architectures)
flutter build apk --release --split-per-abi # un APK plus léger par architecture
```

**Sur iPhone physique** : ouvrir `ios/Runner.xcworkspace` dans Xcode, onglet *Signing & Capabilities*,
choisir une *Team* (Apple ID), lancer une première fois depuis Xcode pour créer le certificat, puis
*faire confiance* au certificat sur l'iPhone (Réglages ▸ Général ▸ VPN et gestion de l'appareil).

## Tester l'intégration GitHub

Dans un profil, appuyer sur **✏️**, renseigner un **pseudo GitHub** public, puis enregistrer : la
section *Dépôts GitHub* charge les dépôts publics.

Dans le formulaire, **pendant la saisie du pseudo**, l'app affiche sous le champ les derniers dépôts
publics du compte (preuve que c'est le bon). À l'enregistrement, l'app **vérifie que le compte existe** : un pseudo inconnu de GitHub est refusé
(message sous le champ). Hors ligne, le CV est enregistré quand même, avec un avertissement.
*(Connexion internet requise ; l'API publique est limitée à 60 requêtes/heure sans authentification.)*

## Vérifications et tests

```bash
flutter analyze          # 0 erreur attendu
flutter test             # 198 tests
flutter test --coverage  # génère coverage/lcov.info
```

Ce qui est couvert : modèles et sérialisation, calcul de complétion, CRUD du
provider (dont l'interdiction des doublons de nom), service GitHub (délai dépassé / hors-ligne, existence d'un compte),
le formulaire de création, quelques widgets, et surtout les
**migrations de la base** (via `sqflite_common_ffi`, pour garantir qu'une mise à jour ne perde
aucune donnée).

## Structure du projet (résumé)

```
lib/
├── main.dart                  # Point d'entrée
├── app/                       # Racine, thème, navigation, À propos, Réglages
├── core/                      # Base SQLite (schéma + migrations), transitions
├── shared/
│   ├── models/                # Student, Skill, Project, ExperienceEntry
│   └── widgets/               # Composants réutilisables (pilules, feuilles)
└── features/
    ├── portfolio/
    │   ├── data/              # Repository + données d'exemple
    │   ├── domain/            # Complétion du profil
    │   ├── providers/         # État (Provider)
    │   ├── presentation/      # Écrans et widgets
    │   └── services/          # Génération du PDF
    └── github/                # Intégration de l'API GitHub
```

## Limites connues / améliorations possibles

- **Aucune sauvegarde** : pas de synchronisation en ligne ni d'export des données. Elles vivent
  uniquement sur l'appareil ; supprimer l'app ou changer de téléphone les efface.
- **Android hors cible** : l'app est conçue pour l'iPhone. L'APK release compile mais n'a jamais été
  lancé ; il est signé avec la **clé de debug** et garde l'identifiant `com.example.myportfolio`
  (tous deux refusés par le Play Store).
- Couverture de tests ≈ 78 % : logique, écrans, export PDF et formulaires couverts ; le choix de
  photo et l'ouverture de liens (services du téléphone) ne sont pas testés automatiquement.
- Export PDF : la police intégrée ne connaît que le Latin-1. La ponctuation typographique est
  remplacée (« — » → « - », « ’ » → « ' »), mais les émoji et l'écriture arabe sont retirés.
- Avec un compte Apple gratuit, le profil de développement iOS expire après ~7 jours
  (relancer depuis Xcode pour le renouveler).
