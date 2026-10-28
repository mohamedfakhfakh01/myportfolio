# apprentissage.md — MyPortfolio

> Support pédagogique du projet **MyPortfolio** (module Développement Mobile).
> Ce fichier est mis à jour **au fur et à mesure** du développement : il doit toujours
> refléter le **code réel** du projet, et non une architecture théorique.
>
> Sections prévues : **A.** Présentation · **B.** Structure des fichiers · **C.** Explication du code ·
> **D.** Notions Flutter/Dart · **E.** Dépendances · **F.** Parcours d'exécution ·
> **G.** Questions d'évaluation · **H.** Difficultés · **I.** Historique des décisions · **J.** Journal des étapes.
>
> Toutes les sections (A à J) sont désormais remplies et reflètent le **code réel** du projet.

---

## A. Présentation générale

### Objectif de l'application
**MyPortfolio** est une application mobile permettant à des étudiants de **valoriser leur parcours
académique, leurs compétences et leurs projets** à travers un portfolio numérique personnel,
interactif et évolutif.

### Problème résolu
Un étudiant n'a pas toujours un outil simple et mobile pour **présenter** et **mettre à jour**
son parcours. MyPortfolio centralise ces informations dans une application qui les **conserve**
localement et peut les **enrichir** avec des données externes (projets GitHub).

### Contexte particulier
Le projet est réalisé **en binôme**. L'application héberge **deux portfolios indépendants**
(un par membre du binôme) dans une seule et même application.

### Fonctionnalités principales (demandées par le sujet)
1. Consulter les **deux portfolios** étudiants.
2. Afficher les **informations personnelles et académiques**.
3. Mettre en valeur les **compétences** et les **projets réalisés**.
4. **Ajouter / modifier / supprimer** certaines informations (CRUD).
5. **Conserver les données** après la fermeture de l'application (persistance locale).
6. Intégrer des données d'un **service externe via une API REST**.
7. Offrir une **navigation fluide** entre les sections.

### Technologies utilisées
- **Flutter 3.47.4** (canal stable) — framework d'interface multiplateforme.
- **Dart 3.13.3** — langage de programmation.
- **Provider** — gestion de l'état de l'application.
- **sqflite** — base de données locale SQLite (persistance).
- **http** — appels réseau vers l'API REST (GitHub).
- **google_fonts** — typographie (police Poppins).

### Architecture choisie (vue d'ensemble)
Architecture **« feature-first » simplifiée** : le code est organisé par **fonctionnalité**
(portfolio, compétences, projets, intégration GitHub), avec à l'intérieur une séparation
en trois rôles :

```
presentation/  →  ce que l'utilisateur voit (écrans + widgets)
providers/     →  l'état et la logique (Provider) — fait le lien
data/          →  l'accès aux données (base sqflite + API GitHub)
```

Règle d'or : **un écran ne parle jamais directement à la base de données**.
Il passe toujours par un `Provider`. Analogie du restaurant : la salle (écran) commande au
serveur (Provider), qui va voir la cuisine (data) ; la salle ne va jamais en cuisine elle-même.

---

## B. Structure des fichiers

### B.1 — État réel du projet (après l'étape 6 : écran d'accueil)
Le projet contient la structure générée par `flutter create`, enrichie de notre code : le système
de design (`lib/app/theme/`), les modèles (`lib/shared/models/`) et la fonctionnalité portfolio
(`lib/features/portfolio/`).

```
myportfolio/
├── lib/
│   ├── main.dart            # Point d'entrée — lance MyPortfolioApp (minimal)
│   ├── app/
│   │   ├── app.dart         # Widget racine : Provider + MaterialApp + thème + accueil
│   │   └── theme/
│   │       ├── app_colors.dart            # Palette de couleurs centralisée
│   │       ├── app_theme.dart             # ThemeData (Material 3) : couleurs, Poppins, styles
│   │       └── theme_showcase_page.dart   # Ancienne vitrine du thème (désormais inutilisée)
│   ├── core/
│   │   ├── database/
│   │   │   └── app_database.dart          # Ouvre la base SQLite + crée les 3 tables
│   │   └── widgets/
│   │       └── fade_slide_route.dart      # Transition de page (fondu + glissement)
│   ├── shared/
│   │   └── models/
│   │       ├── student.dart   # Modèle Étudiant (+ listes de compétences et projets)
│   │       ├── skill.dart     # Modèle Compétence
│   │       └── project.dart   # Modèle Projet
│   └── features/
│       ├── portfolio/
│           ├── data/
│           │   ├── sample_portfolio_data.dart   # Données de départ (seed) : Houssain + Mohamed
│           │   └── portfolio_repository.dart     # Accès base : lecture + CRUD SQL + seed
│           ├── providers/
│           │   └── portfolio_provider.dart      # État : liste des étudiants (ChangeNotifier)
│           └── presentation/
│               ├── pages/
│               │   ├── home_page.dart           # Écran d'accueil (liste des 2 portfolios)
│               │   └── profile_page.dart        # Écran profil (détail d'un étudiant)
│               └── widgets/
│                   ├── student_card.dart        # Carte étudiant réutilisable
│                   ├── student_avatar.dart       # Avatar (photo ou initiales), animé (Hero)
│                   ├── skill_chip.dart          # Puce de compétence (tappable)
│                   ├── project_card.dart        # Carte de projet (tappable)
│                   ├── skill_form_dialog.dart   # Formulaire ajout/modif d'une compétence
│                   ├── project_form_dialog.dart # Formulaire ajout/modif d'un projet
│                   └── student_edit_dialog.dart # Formulaire d'édition du profil
│       └── github/
│           ├── data/
│           │   ├── github_repo.dart       # Modèle d'un dépôt GitHub (+ fromJson)
│           │   └── github_service.dart     # Appel HTTP à l'API GitHub + parsing JSON
│           └── presentation/
│               └── widgets/
│                   ├── github_repo_card.dart    # Carte d'un dépôt
│                   └── github_repos_section.dart # Section Dépôts GitHub (FutureBuilder)
├── test/
│   └── widget_test.dart     # Test « fumée » : l'app démarre et affiche le titre
├── android/                 # Projet natif Android (généré)
├── ios/                     # Projet natif iOS (généré)
├── pubspec.yaml             # Déclaration des dépendances et métadonnées du projet
├── pubspec.lock             # Versions exactes verrouillées des dépendances
├── analysis_options.yaml    # Règles d'analyse/qualité du code Dart
└── apprentissage.md         # Ce fichier (documentation pédagogique)
```

| Fichier | Rôle |
|---------|------|
| `lib/main.dart` | Point d'entrée de l'application. C'est la première chose exécutée. |
| `pubspec.yaml` | « Carte d'identité » du projet : nom, version, **dépendances**. |
| `pubspec.lock` | Fige les **versions exactes** installées (reproductibilité). |
| `analysis_options.yaml` | Active les règles de **qualité** (ce que `flutter analyze` vérifie). |
| `android/`, `ios/` | Code natif de chaque plateforme, généré automatiquement. |
| `lib/app/app.dart` | Widget racine : crée le `MaterialApp` et applique le thème. |
| `lib/app/theme/app_colors.dart` | Toutes les couleurs de l'app, à un seul endroit. |
| `lib/app/theme/app_theme.dart` | Le `ThemeData` : relie couleurs, police et styles de composants. |
| `lib/app/theme/theme_showcase_page.dart` | Ancienne vitrine du thème (plus utilisée). |
| `lib/shared/models/*.dart` | Les modèles de données : `Student`, `Skill`, `Project`. |
| `lib/features/portfolio/data/sample_portfolio_data.dart` | Données d'exemple (placeholder `TODO`). |
| `lib/features/portfolio/providers/portfolio_provider.dart` | État : la liste des étudiants (`ChangeNotifier`). |
| `lib/features/portfolio/presentation/pages/home_page.dart` | Écran d'accueil (liste des 2 portfolios). |
| `lib/features/portfolio/presentation/widgets/student_card.dart` | Carte étudiant réutilisable. |
| `lib/features/portfolio/presentation/pages/profile_page.dart` | Écran profil détaillé d'un étudiant. |
| `lib/features/portfolio/presentation/widgets/skill_chip.dart` | Puce d'une compétence. |
| `lib/features/portfolio/presentation/widgets/project_card.dart` | Carte d'un projet. |
| `lib/core/database/app_database.dart` | Ouvre la base SQLite et crée les 3 tables. |
| `lib/features/portfolio/data/portfolio_repository.dart` | Lecture, CRUD SQL et seed de la base. |
| `lib/features/portfolio/presentation/widgets/skill_form_dialog.dart` | Formulaire d'ajout/modif d'une compétence. |
| `lib/features/portfolio/presentation/widgets/project_form_dialog.dart` | Formulaire d'ajout/modif d'un projet. |
| `lib/features/portfolio/presentation/widgets/student_edit_dialog.dart` | Formulaire d'édition du profil. |
| `lib/features/github/data/github_repo.dart` | Modèle d'un dépôt GitHub. |
| `lib/features/github/data/github_service.dart` | Appel HTTP à l'API GitHub + parsing JSON. |
| `lib/features/github/presentation/widgets/github_repo_card.dart` | Carte d'un dépôt GitHub. |
| `lib/features/github/presentation/widgets/github_repos_section.dart` | Section « Dépôts GitHub » (FutureBuilder). |

### B.2 — Arborescence cible (à construire progressivement, PAS encore créée)
Nous créerons ces dossiers **au fur et à mesure** que nous y mettrons du vrai code, pour éviter
les dossiers vides :

```
lib/
├── main.dart
├── app/
│   ├── app.dart             # Widget racine (MaterialApp, thème, routes)
│   ├── theme/               # Couleurs, typographie, styles (identité visuelle)
│   └── router/              # Navigation entre les écrans
├── core/
│   ├── constants/           # Valeurs fixes (URL de l'API, etc.)
│   ├── database/            # Ouverture de la base sqflite
│   └── widgets/             # Widgets réutilisables génériques
├── features/
│   ├── portfolio/           # Étudiants / profils
│   │   ├── data/            # Modèles + accès base (repository)
│   │   ├── presentation/
│   │   │   ├── pages/       # Écrans
│   │   │   └── widgets/     # Widgets propres à la feature
│   │   └── providers/       # État (Provider)
│   ├── skills/              # Compétences (CRUD)
│   ├── projects/            # Projets (CRUD)
│   └── github/              # Intégration API REST externe
└── shared/
    └── models/             # Modèles partagés (Student, Skill, Project)
```

> ⚠️ Cette arborescence est un **objectif**, pas l'état actuel. La section B.1 sera mise à jour
> dès que des dossiers réels seront créés.

---

## C. Explication du code (étapes 5–8)

### `lib/app/theme/app_colors.dart`
- `class AppColors { AppColors._(); ... }` : classe « boîte à constantes ». Le constructeur
  **privé** `AppColors._()` (le `_` rend l'élément privé au fichier) empêche de créer un objet
  `AppColors()` : on utilise seulement `AppColors.primary`, etc.
- `static const Color primary = Color(0xFF4F46E5);` : `static` = la valeur appartient à la classe
  (pas à un objet) ; `const` = constante connue à la compilation ; `Color(0xFF……)` = couleur au
  format ARGB (`FF` = opacité totale, puis RVB).

### `lib/app/theme/app_theme.dart`
- `static ThemeData get light { ... }` : un **getter** statique qui construit et renvoie le thème.
- `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(...))` : on part d'une couleur
  « graine » et Flutter génère une palette Material 3 cohérente.
- `base.copyWith(...)` : on **copie** le thème de base en **remplaçant** certains champs par nos
  choix (texte, boutons, champs, cartes). `copyWith` évite de tout réécrire.
- `base.textTheme.apply(fontFamily: GoogleFonts.poppins().fontFamily, ...)` : applique la police
  Poppins et nos couleurs de texte à tous les styles.
- `elevatedButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `cardTheme` : styles par
  défaut appliqués automatiquement à **tous** les boutons, champs et cartes → cohérence garantie.
  `minimumSize: Size.fromHeight(52)` assure une zone tactile confortable (≥ 48 px).

### `lib/app/app.dart`
- `class MyPortfolioApp extends StatelessWidget` : le widget racine, **sans état** (il ne change
  pas tout seul).
- `MaterialApp(theme: AppTheme.light, home: const ThemeShowcasePage())` : fournit le thème à toute
  l'app et définit l'écran de départ. `debugShowCheckedModeBanner: false` masque le bandeau « Debug ».

### `lib/main.dart`
- `void main() { runApp(const MyPortfolioApp()); }` : point d'entrée. `runApp` affiche le widget
  racine à l'écran. Fichier gardé minimal (la configuration est dans `app/app.dart`).

### `lib/app/theme/theme_showcase_page.dart`
- `Scaffold` : squelette d'un écran (barre + corps). `AppBar` = barre du haut.
- `Theme.of(context).textTheme` : récupère les styles de texte du thème courant.
- `Card`, `CircleAvatar`, `Wrap`, `TextField`, `ElevatedButton`, `OutlinedButton` : widgets de
  démonstration. `_SkillChip` est un petit widget **privé réutilisable** (puce de compétence).

### `lib/shared/models/` — les modèles (étape 6)
- `class Skill`, `class Project`, `class Student` : classes qui décrivent les données métier.
- Champs `final` : une fois l'objet créé, ses valeurs ne changent plus (immuable = plus sûr).
- `final int? id;` : le `?` indique une valeur qui peut être **nulle** — ici tant que l'objet
  n'est pas enregistré en base.
- `List<Skill> skills` : une **liste typée** (ne peut contenir que des `Skill`).
- `String get initials { ... }` : un **getter** qui calcule les initiales à partir du nom.

### `lib/features/portfolio/data/sample_portfolio_data.dart` — données des portfolios
- `const List<Student> sampleStudents = [ ... ]` : la liste des 2 étudiants.
  - Étudiant 2 (**Houssain Aloulou**) : **vraies données** issues de son CV (sans coordonnées
    privées : ni téléphone ni e-mail).
  - Étudiant 1 (**Mohamed Fakhfakh**) : à compléter (`TODO`).
- Les niveaux de compétence (`level`) sont laissés `null` quand ils ne sont pas connus (on
  n'invente aucune valeur). Ces données viendront de la base sqflite à l'étape 8.

### `lib/features/portfolio/providers/portfolio_provider.dart` — l'état
- `class PortfolioProvider extends ChangeNotifier` : contient la liste des étudiants ; pourra
  prévenir les écrans quand elle change (`notifyListeners()`), lors du CRUD.
- `List<Student> get students => List.unmodifiable(_students);` : liste exposée en **lecture
  seule** pour empêcher toute modification accidentelle depuis l'extérieur.

### `lib/features/portfolio/presentation/pages/home_page.dart` — l'écran d'accueil
- `context.watch<PortfolioProvider>().students` : l'écran **écoute** le provider ; si la liste
  change, il se reconstruit automatiquement.
- `for (final student in students) ...[ ... ]` : une boucle `for` directement dans la liste de
  widgets (« collection-for ») pour créer une carte par étudiant.
- `_EmptyState` : widget d'**état vide** affiché s'il n'y a aucun étudiant (bonne UX).

### `lib/features/portfolio/presentation/widgets/student_card.dart` — la carte étudiant
- Widget **réutilisable** recevant un `Student` et un `onTap` (`VoidCallback`).
- `InkWell(onTap: ...)` : rend la carte **cliquable** avec un effet visuel au toucher.
- `student.initials` affiché dans un `CircleAvatar`.

### `skill_chip.dart` et `project_card.dart` — widgets réutilisables (profil)
- `SkillChip` : une compétence en puce ; le niveau n'est affiché que s'il est connu.
- `ProjectCard` : titre, description et lien **éventuel**.
- `if (project.link != null) ...[ ... ]` : le lien n'est affiché que s'il existe (pas d'invention).

### `lib/features/portfolio/presentation/pages/profile_page.dart` — l'écran profil
- Reçoit un `Student` via son constructeur et affiche : en-tête (avatar/nom/filière), bio,
  compétences et projets.
- **États vides** : si `skills` ou `projects` est vide, un petit message s'affiche (bonne UX).
- `AppBar(title: Text(student.fullName))` fournit automatiquement la **flèche de retour**.

### Navigation (dans `home_page.dart`)
- `Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfilePage(student: student)))` :
  **empile** l'écran profil au-dessus de l'accueil ; la flèche de retour le **retire** de la pile.

### Persistance — sous-étape 8.1 (fondation de la base)
- **`toMap()` / `fromMap()`** (dans `skill.dart`, `project.dart`, `student.dart`) : convertissent un
  objet Dart en `Map` (une ligne de base) et inversement. `factory Skill.fromMap(...)` est un
  **constructeur de fabrique**.
- **`copyWith(...)`** (dans `student.dart`) : renvoie une copie en ne changeant que certains champs
  (utile pour rattacher les compétences/projets, et pour l'édition du profil en 8.6).
- **`lib/core/database/app_database.dart`** :
  - patron **singleton** (`AppDatabase.instance`) → une seule connexion à la base dans toute l'app ;
  - `openDatabase(path, version: 1, onCreate: ...)` ouvre/crée le fichier `myportfolio.db` ;
  - `PRAGMA foreign_keys = ON` : SQLite n'applique pas les clés étrangères par défaut, on les active ;
  - `onCreate` exécute les `CREATE TABLE` (students, skills, projects) **une seule fois**.

### Persistance — sous-étape 8.2 (repository + seed)
- **`lib/features/portfolio/data/portfolio_repository.dart`** : la seule classe qui lit/écrit la base.
  - `getStudents()` : lit la table `students`, puis pour chacun ses `skills` et `projects`
    (requêtes `where: 'studentId = ?'`), et assemble le tout avec `copyWith`.
  - `seedIfEmpty()` : si la base est **vide**, insère les données de départ (Houssain + Mohamed).
    `Sqflite.firstIntValue(... COUNT(*) ...)` lit le nombre de lignes.
  - CRUD : `insertSkill/updateSkill/deleteSkill`, `insertProject/updateProject/deleteProject`,
    `updateStudent`.
- Les méthodes utilisent `db.insert/update/delete` avec `where: 'id = ?'` et `whereArgs` : ce sont
  des **requêtes paramétrées** (les valeurs passent par `?`), ce qui protège des injections SQL.
- À l'insertion, on retire l'`id` local (`toMap()..remove('id')`) pour laisser SQLite l'attribuer.

### Persistance — sous-étape 8.3 (branchement du Provider)
- **`PortfolioProvider`** charge désormais les données depuis le repository :
  - au démarrage, son constructeur appelle `load()` ;
  - `load()` fait `seedIfEmpty()` puis `getStudents()` (opérations **asynchrones** → `await`) ;
  - trois états exposés à l'UI : `isLoading`, `error`, et la liste `students` ;
  - un bloc `try / catch / finally` capture toute erreur de base → l'app ne plante jamais.
- **`home_page.dart`** réagit à ces états : indicateur de chargement, écran d'erreur avec bouton
  « Réessayer », sinon la liste (ou l'état vide).
- **Injection de dépendance** : le provider accepte un `repository` optionnel → on pourra lui
  donner un faux repository dans les tests.

### Persistance — sous-étape 8.4 (CRUD des compétences)
- **`PortfolioProvider`** : nouvelles méthodes `addSkill`, `updateSkill`, `deleteSkill`. Chacune
  écrit en base via le repository, puis `_reloadStudents()` relit la base et notifie l'UI.
- **`skill_form_dialog.dart`** : une boîte de dialogue (`showDialog`) avec un **formulaire**
  (`Form` + `TextFormField`) : nom (obligatoire) et niveau (optionnel, 0–100).
  - Validation via `validator` + `_formKey.currentState!.validate()`.
  - `inputFormatters: [FilteringTextInputFormatter.digitsOnly]` limite le niveau aux chiffres.
  - Suppression avec **confirmation** (action destructive).
  - `if (!mounted) return;` après chaque `await` : on n'utilise `context` que si l'écran existe encore.
- **`profile_page.dart`** devient **réactif** : il reçoit un `studentId` et lit l'étudiant à jour via
  `context.watch<PortfolioProvider>().studentById(id)` → après un ajout/suppression, l'écran se
  rafraîchit tout seul. Bouton **＋** pour ajouter, chips **tappables** pour modifier/supprimer.

### Persistance — sous-étape 8.5 (CRUD des projets)
- Même schéma que les compétences, appliqué aux projets :
  - **`PortfolioProvider`** : `addProject`, `updateProject`, `deleteProject` (+ rechargement) ;
  - **`project_form_dialog.dart`** : formulaire avec titre et description **obligatoires**, lien
    **optionnel** ; suppression avec confirmation ;
  - **`project_card.dart`** devient **tappable** (`onTap`) → ouvre la modification ;
  - **`profile_page.dart`** : bouton **＋** « Projets » et cartes modifiables.

### Persistance — sous-étape 8.6 (édition du profil)
- **`PortfolioProvider.updateStudent(student)`** : enregistre les champs du profil puis recharge.
- **`student_edit_dialog.dart`** : formulaire (nom + filière obligatoires, bio + GitHub optionnels).
  On reconstruit l'étudiant en gardant son `id`, ses compétences et projets, et en remplaçant les
  champs modifiés (le pseudo GitHub peut être vidé → remis à `null`).
- **`profile_page.dart`** : un bouton **✏️** dans l'`AppBar` (`actions`) ouvre ce formulaire.

### API GitHub — sous-étape 9.1 (modèle + service)
- **`github_repo.dart`** : modèle d'un dépôt + `GithubRepo.fromJson(...)` qui traduit le JSON de
  l'API (`stargazers_count`, `html_url`…) vers nos propres champs.
- **`github_service.dart`** :
  - `http.get(uri)` envoie une requête **GET** à `api.github.com` ;
  - `jsonDecode(response.body)` transforme le texte JSON reçu en objets Dart ;
  - on réagit au **code de réponse** HTTP : 200 (OK), 404 (introuvable), 403 (limite atteinte) ;
  - les erreurs sont levées comme `GithubException` avec un message clair pour l'utilisateur ;
  - le `http.Client` est **injectable** (remplaçable par un faux en test).

### API GitHub — sous-étape 9.2 (affichage via FutureBuilder)
- **`github_repos_section.dart`** : un `StatefulWidget` qui crée la requête **une seule fois**
  (`initState`) et l'affiche avec un **`FutureBuilder`** :
  - `ConnectionState.waiting` → indicateur de chargement ;
  - `snapshot.hasError` → message d'erreur + bouton « Réessayer » (`setState` relance la requête) ;
  - sinon → la liste des dépôts (ou « aucun dépôt public »).
  - `didUpdateWidget` relance la requête si le pseudo change (après édition du profil).
- **`github_repo_card.dart`** : carte d'un dépôt (nom, description, langage, ⭐ étoiles).
- **`profile_page.dart`** : la section « Dépôts GitHub » n'apparaît **que si** `githubUsername` est
  renseigné.

## D. Notions Flutter et Dart (introduites à l'étape 5)

| Notion | Définition simple | Utilité ici | Exemple (code réel) |
|--------|-------------------|-------------|---------------------|
| `StatelessWidget` | Un composant d'interface **sans état interne** qui change. | `MyPortfolioApp`, écran vitrine. | `class MyPortfolioApp extends StatelessWidget` |
| `build(BuildContext context)` | Méthode qui **décrit** ce que le widget affiche. | Appelée par Flutter pour dessiner l'écran. | `Widget build(BuildContext context) { return MaterialApp(...); }` |
| Constructeur `const` + `super.key` | Crée un objet constant et transmet la « clé » au parent. | Performance (Flutter réutilise les widgets constants). | `const MyPortfolioApp({super.key});` |
| `static` / `get` | Membre lié à la classe / propriété calculée. | Accéder au thème sans créer d'objet. | `static ThemeData get light` |
| `ThemeData` / `ColorScheme.fromSeed` | Le thème global / une palette dérivée d'une couleur. | Cohérence visuelle de toute l'app. | `ColorScheme.fromSeed(seedColor: AppColors.primary)` |
| `copyWith(...)` | Copie un objet en modifiant quelques champs. | Partir du thème de base et le personnaliser. | `base.copyWith(appBarTheme: ...)` |

*Alternative notée :* on aurait pu tout styliser à la main sur chaque écran, mais un **thème
centralisé** évite la répétition et garde une identité cohérente (meilleur choix professionnel).

### Notions ajoutées à l'étape 6

| Notion | Définition simple | Utilité ici | Exemple (code réel) |
|--------|-------------------|-------------|---------------------|
| Classe modèle | Classe qui décrit une donnée métier. | `Student`, `Skill`, `Project`. | `class Skill { final String name; ... }` |
| Type nullable `?` | Une valeur qui peut être `null`. | `id` non défini tant que non enregistré. | `final int? id;` |
| Générique `List<T>` | Liste ne contenant qu'un seul type. | Liste de compétences. | `List<Skill> skills` |
| `ChangeNotifier` + `provider` | Objet d'état qui prévient l'UI de ses changements. | Gérer la liste des étudiants. | `class PortfolioProvider extends ChangeNotifier` |
| `context.watch<T>()` | Écoute un provider et reconstruit à chaque changement. | Afficher la liste à jour. | `context.watch<PortfolioProvider>().students` |
| Collection-for | Boucle `for` dans une liste de widgets. | Une carte par étudiant. | `for (final s in students) ...[ StudentCard(...) ]` |
| `InkWell` | Zone tactile avec effet d'ondulation. | Rendre la carte cliquable. | `InkWell(onTap: onTap, child: ...)` |
| `Navigator` + `MaterialPageRoute` | Empiler/retirer des écrans (navigation). | Ouvrir le profil depuis l'accueil. | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfilePage(...)))` |

*Alternative notée :* pour seulement afficher 2 étudiants, on aurait pu passer les données
directement sans `Provider`. On l'introduit dès maintenant car il sera **indispensable** pour le
CRUD (étape 8) : autant structurer tout de suite.

### Notions ajoutées à l'étape 8 (persistance)

| Notion | Définition simple | Utilité ici | Exemple (code réel) |
|--------|-------------------|-------------|---------------------|
| `factory` | Constructeur qui exécute un peu de logique avant de renvoyer l'objet. | Construire un objet depuis un `Map`. | `factory Skill.fromMap(map) => Skill(...)` |
| `Future` / `async` / `await` | Valeur disponible **plus tard** (opération asynchrone). | Ouvrir la base prend un instant. | `Future<Database> get database async { ... }` |
| Singleton | Une seule instance partagée d'une classe. | Une seule connexion à la base. | `static final AppDatabase instance = AppDatabase._();` |
| Clé étrangère (SQL) | Colonne qui référence la ligne d'une autre table. | Lier compétences/projets à leur étudiant. | `FOREIGN KEY (studentId) REFERENCES students(id)` |
| Requête paramétrée | Passer les valeurs via `?` + `whereArgs` (pas collées dans le SQL). | Éviter les injections SQL. | `db.delete('skills', where: 'id = ?', whereArgs: [id])` |
| `try` / `catch` / `finally` | Capturer une erreur sans planter ; `finally` s'exécute toujours. | Gérer un échec de la base proprement. | `try { ... } catch (e) { _error = ...; } finally { _isLoading = false; }` |
| État de chargement | Un booléen qui dit si les données arrivent encore. | Afficher un indicateur pendant la lecture de la base. | `if (provider.isLoading) return CircularProgressIndicator();` |
| `Form` + `TextFormField` + `validator` | Saisie **validée** (champ obligatoire, format). | Formulaire d'une compétence. | `validator: (v) => v!.trim().isEmpty ? 'obligatoire' : null` |
| `showDialog` | Ouvre une fenêtre modale par-dessus l'écran. | Formulaire d'ajout/modif, confirmation de suppression. | `showDialog(context: ..., builder: ...)` |
| `mounted` après `await` | Vérifier que le widget existe encore avant d'utiliser `context`. | Éviter un plantage après une opération asynchrone. | `await ...; if (!mounted) return;` |

### Notions ajoutées à l'étape 9 (API REST)

| Notion | Définition simple | Utilité ici | Exemple (code réel) |
|--------|-------------------|-------------|---------------------|
| `http.get` | Envoyer une requête web GET. | Appeler l'API GitHub. | `await _client.get(uri)` |
| `jsonDecode` | Transformer du texte JSON en objets Dart. | Lire la réponse de l'API. | `jsonDecode(response.body) as List` |
| Code de réponse HTTP | 200 = OK, 404 = introuvable, 403 = refusé… | Réagir correctement à l'API. | `if (response.statusCode == 200) { ... }` |
| `FutureBuilder` | Widget qui se reconstruit selon l'état d'un `Future` (en cours / fini / erreur). | Afficher les dépôts quand ils arrivent. | `FutureBuilder(future: _future, builder: (ctx, snap) {...})` |

## E. Bibliothèques et dépendances (utilisées à l'étape 5)

### `google_fonts` (^9.0.0)
- **Rôle** : charger des polices Google (ici **Poppins**) sans les télécharger manuellement.
- **Où** : `app_theme.dart`, via `GoogleFonts.poppins().fontFamily` appliqué au `textTheme`.
- **Fonctionnement** : la police est récupérée au premier lancement puis mise en cache.
- **Limite / à savoir** : au tout premier affichage, une connexion Internet est nécessaire
  (ensuite c'est en cache). On pourra, si besoin, **embarquer** la police dans l'app pour un
  fonctionnement 100 % hors-ligne.
- **Alternative** : utiliser une police système (gratuit, hors-ligne) — mais moins personnalisé.

### `provider` (^6.1.5)
- **Rôle** : gérer l'**état** de l'application de façon simple et lisible.
- **Où** : `PortfolioProvider` (liste des étudiants), fourni dans `app.dart` via
  `ChangeNotifierProvider`, écouté dans `home_page.dart` via `context.watch`.
- **Fonctionnement** : un `ChangeNotifier` notifie ses auditeurs (`notifyListeners`) ; les widgets
  abonnés se reconstruisent automatiquement.
- **Alternative** : `setState` (plus simple mais limité à un seul widget), `Bloc`/`Riverpod`
  (plus puissants mais plus complexes pour un débutant).

### `sqflite` (^2.4) et `path` (^1.9)
- **`sqflite`** : base de données **SQLite** locale sur l'appareil → c'est elle qui **conserve** les
  données après fermeture (exigence du sujet).
  - **Où** : `core/database/app_database.dart` (ouverture + tables) ; le repository (8.2) fera le CRUD.
  - **Pourquoi SQLite** : du vrai SQL (tables, clés étrangères, requêtes), facile à défendre à l'oral.
- **`path`** : construit des chemins de fichiers de façon portable — ex. `join(folder, 'myportfolio.db')`.
- **Note** : `sqflite` utilise du code natif iOS/Android — c'est pourquoi CocoaPods était requis (voir H.3).

### `http` (^1.6)
- **Rôle** : faire des requêtes réseau (ici, appeler l'API REST publique de GitHub).
- **Où** : `features/github/data/github_service.dart`.
- **Fonctionnement** : `http.get(uri)` renvoie une réponse avec un `statusCode` et un `body` (texte).
- **Alternative** : le paquet `dio` (plus de fonctionnalités) ; `http` suffit ici et reste simple.

### `image_picker` et `path_provider` (photo de profil)
- **`image_picker`** : choisir une image depuis la **galerie** ou l'**appareil photo**.
  - **Où** : `student_edit_dialog.dart` (photo de profil).
  - **Autorisations iOS** : `NSPhotoLibraryUsageDescription` et `NSCameraUsageDescription` (dans
    `ios/Runner/Info.plist`).
- **`path_provider`** : obtenir le dossier de l'application pour y **copier** l'image choisie (afin
  qu'elle persiste). On enregistre ensuite son chemin dans la colonne `photoPath` de la base.

## F. Parcours d'exécution

Du lancement de l'application jusqu'à l'affichage des dépôts GitHub.

### 1. Démarrage
1. `main()` (`lib/main.dart`) exécute `runApp(const MyPortfolioApp())`.
2. `MyPortfolioApp` (`app/app.dart`) crée un `ChangeNotifierProvider` qui instancie le
   `PortfolioProvider`, puis le `MaterialApp` (thème + `home: HomePage`).
3. Le constructeur du `PortfolioProvider` appelle `load()` :
   - `seedIfEmpty()` : si la base est vide (1er lancement), insère Houssain + Mohamed ;
   - `getStudents()` : lit les tables `students`, `skills`, `projects` et assemble les objets ;
   - `isLoading` passe à `false`, puis `notifyListeners()` prévient l'interface.

### 2. Écran d'accueil
4. `HomePage` écoute le provider (`context.watch`). Tant que `isLoading` est vrai → indicateur de
   chargement. Une fois prêt → la liste des 2 étudiants, chacun dans une `StudentCard`.

### 3. Navigation vers le profil
5. Au toucher d'une carte : `Navigator.push(MaterialPageRoute(... ProfilePage(studentId: ...)))`
   **empile** l'écran profil.
6. `ProfilePage` lit l'étudiant **à jour** via `context.watch(...).studentById(id)` et affiche
   en-tête, bio, compétences et projets.

### 4. Ajouter une compétence (exemple complet CRUD + persistance)
7. Bouton ➕ → `showSkillFormDialog` ouvre le formulaire.
8. À « Enregistrer », après validation → `provider.addSkill(studentId, skill)`.
9. Le provider appelle `repository.insertSkill(...)` → `db.insert('skills', ...)` (requête
   **paramétrée**) → SQLite écrit sur le disque.
10. `_reloadStudents()` relit la base, `notifyListeners()` → `ProfilePage` se reconstruit → la
    compétence apparaît. Elle **persiste** car elle est stockée sur le disque.

### 5. Afficher les dépôts GitHub
11. Si l'étudiant a un `githubUsername`, `ProfilePage` affiche `GithubReposSection`.
12. Dans son `initState`, la section crée **une seule fois** `GithubService().fetchRepos(username)`.
13. `fetchRepos` : `http.get('https://api.github.com/users/<pseudo>/repos')` → selon le code
    (200 / 404 / 403), `jsonDecode` transforme le JSON en `List<GithubRepo>` ou lève une erreur.
14. Le `FutureBuilder` affiche l'indicateur de chargement, puis la liste de `GithubRepoCard`, ou un
    message d'erreur avec un bouton « Réessayer ».

## G. Questions possibles à l'évaluation

Pour chaque question : une **réponse courte** (à dire à l'oral), un **détail**, et le **fichier** concerné.

### Q1 — Quelle architecture as-tu choisie, et pourquoi ?
- **Courte** : « Une architecture *feature-first* simplifiée, en 3 couches : présentation (écrans),
  état (Provider), données (repository + base). »
- **Détail** : chaque couche a une responsabilité ; l'écran ne touche jamais la base directement,
  il passe par le Provider puis le repository. J'ai évité la Clean Architecture complète, trop
  lourde pour ce projet.
- **Où** : `lib/features/`, `lib/core/`, `lib/shared/`.

### Q2 — Différence entre `StatelessWidget` et `StatefulWidget` ?
- **Courte** : « Un `StatelessWidget` n'a pas d'état interne qui change ; un `StatefulWidget` oui. »
- **Détail** : `HomePage` et `ProfilePage` sont *stateless* (elles lisent l'état via Provider) ; les
  formulaires et `GithubReposSection` sont *stateful* (ils gardent des `TextEditingController` ou la
  requête créée une seule fois).
- **Où** : `skill_form_dialog.dart`, `github_repos_section.dart`.

### Q3 — Comment gères-tu l'état de l'application ?
- **Courte** : « Avec `Provider` et un `ChangeNotifier`. »
- **Détail** : `PortfolioProvider` détient la liste des étudiants ; `context.watch` abonne un écran,
  `notifyListeners()` déclenche sa reconstruction. Choisi car propre et plus simple que Bloc pour mon
  niveau.
- **Où** : `portfolio_provider.dart`.

### Q4 — Comment les données sont-elles conservées après fermeture ?
- **Courte** : « Dans une base de données locale **SQLite**, via le paquet `sqflite`. »
- **Détail** : 3 tables (students, skills, projects), ouvertes par `AppDatabase` ; toutes les
  opérations passent par `PortfolioRepository`. Les données survivent à la fermeture de l'app.
- **Où** : `core/database/app_database.dart`, `data/portfolio_repository.dart`.

### Q5 — Explique les relations entre tes tables.
- **Courte** : « C'est du *un-à-plusieurs* : un étudiant a plusieurs compétences et projets, reliés
  par une **clé étrangère** `studentId`. »
- **Détail** : `FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE` ; et
  `PRAGMA foreign_keys = ON` car SQLite ne vérifie pas les clés étrangères par défaut.
- **Où** : `app_database.dart`.

### Q6 — Qu'est-ce qu'un `FutureBuilder` et pourquoi l'utiliser ?
- **Courte** : « Un widget qui se reconstruit automatiquement selon l'état d'une opération
  asynchrone : en cours, terminée, ou en erreur. »
- **Détail** : utilisé pour l'appel à l'API GitHub → il affiche le chargement, puis les dépôts ou
  l'erreur, sans gérer l'état à la main. La requête est créée une fois (`initState`) pour ne pas
  rappeler l'API à chaque reconstruction.
- **Où** : `github_repos_section.dart`.

### Q7 — Comment appelles-tu l'API et traites-tu la réponse ?
- **Courte** : « `http.get` vers `api.github.com`, puis `jsonDecode` pour lire le JSON. »
- **Détail** : je vérifie le **code de réponse** (200 OK, 404 introuvable, 403 limite) et je convertis
  chaque élément via `GithubRepo.fromJson`.
- **Où** : `github_service.dart`, `github_repo.dart`.

### Q8 — Que signifient `async` / `await` / `Future` ?
- **Courte** : « Une façon d'attendre un résultat qui arrive *plus tard* sans bloquer l'interface. »
- **Détail** : la base et le réseau renvoient des `Future` ; `await` attend le résultat avant de
  continuer. Exemples : `load()`, `fetchRepos()`.
- **Où** : `portfolio_provider.dart`, `github_service.dart`.

### Q9 — Comment valides-tu les formulaires ?
- **Courte** : « Avec `Form` + `TextFormField` + `validator`, déclenchés par
  `formKey.currentState!.validate()`. »
- **Détail** : nom/titre/description obligatoires, niveau entre 0 et 100. La validation est côté app,
  ce qui suffit ici puisque les données sont locales.
- **Où** : `skill_form_dialog.dart`, `project_form_dialog.dart`.

### Q10 — Comment évites-tu les injections SQL ?
- **Courte** : « J'utilise des **requêtes paramétrées** : `where: 'id = ?', whereArgs: [id]`. »
- **Détail** : les valeurs ne sont jamais collées directement dans la chaîne SQL, donc pas
  d'injection possible.
- **Où** : `portfolio_repository.dart`.

### Q11 — À quoi servent `toMap` / `fromMap` ?
- **Courte** : « À convertir entre mes objets Dart et les lignes de la base, qui sont des `Map`. »
- **Détail** : `toMap` pour écrire, `fromMap` (un `factory`) pour relire. Le `studentId` est ajouté
  par le repository à l'insertion.
- **Où** : `student.dart`, `skill.dart`, `project.dart`.

### Q12 — Comment navigues-tu entre les écrans ?
- **Courte** : « `Navigator.push` empile un écran ; la flèche de retour le retire. »
- **Détail** : je passe l'`id` de l'étudiant à `ProfilePage`, qui lit la version à jour via le
  Provider.
- **Où** : `home_page.dart`.

### Q13 — Que se passe-t-il en cas d'erreur (base ou réseau) ?
- **Courte** : « L'app ne plante pas : j'affiche un message clair et un bouton *Réessayer*. »
- **Détail** : `try/catch` dans `PortfolioProvider.load()` ; état d'erreur du `FutureBuilder` pour
  l'API.
- **Où** : `portfolio_provider.dart`, `github_repos_section.dart`.

### Q14 — Pourquoi pas d'authentification ?
- **Courte** : « Le sujet ne la demande pas ; je suis resté simple pour la V1. »
- **Détail** : ce serait une amélioration possible (protéger l'édition), notée dans les limites.

## H. Difficultés rencontrées et solutions

### H.1 — Incompatibilité de type avec `GoogleFonts.poppinsTextTheme`
- **Symptôme** : `flutter analyze` signalait
  `The argument type 'TextTheme' can't be assigned to the parameter type 'TextTheme?'`
  sur l'appel `GoogleFonts.poppinsTextTheme(base.textTheme)`.
- **Diagnostic** : `google_fonts 9.0.0` est la dernière version publiée, mais sa fonction
  `poppinsTextTheme` n'est pas parfaitement compatible avec la version **très récente** de Flutter
  (3.47). Ce n'est donc pas un problème de « version en retard ».
- **Solution** : appliquer la police autrement, via
  `base.textTheme.apply(fontFamily: GoogleFonts.poppins().fontFamily, ...)`. C'est un motif
  **officiel et robuste**, pas un contournement qui masque l'erreur.
- **Vérification** : `flutter analyze` → 0 erreur ; `flutter test` → test « fumée » réussi.

### H.2 — Build iOS impossible à cause des espaces dans le chemin
- **Symptôme** : `flutter build ios` échouait avec `ProcessException: No such file or directory`
  (status 255), alors que `flutter analyze` et `flutter test` passaient sans problème.
- **Diagnostic** : le dossier s'appelait `Projet DS flutter ` (espaces + espace final). Flutter ne
  supporte **pas** les espaces dans le chemin pour les **builds natifs** (les scripts Xcode cassent
  sur les espaces). Le Dart pur (`analyze`/`test`) n'était pas affecté, ce qui masquait le problème.
- **Solution** : déplacer le projet vers `~/Projects/myportfolio` (sans espaces), puis
  `flutter clean` + `flutter pub get` + reconstruction.
- **Vérification** : `flutter build ios --debug --no-codesign` → succès (exit 0).
- **Leçon** : toujours créer un projet Flutter dans un chemin **sans espaces ni accents**.

### H.3 — Déploiement sur un iPhone physique (compte Apple gratuit)
- **Contexte** : aucun simulateur iOS installé sur la machine → test sur un vrai iPhone (iOS 27).
- **Étapes qui ont été nécessaires** :
  1. Installer **CocoaPods** (`brew install cocoapods`) — requis car `sqflite` a du code natif iOS.
  2. Activer le **Mode développeur** sur l'iPhone (Réglages ▸ Confidentialité et sécurité).
  3. Ajouter son **Apple ID** dans Xcode (Settings ▸ Accounts) → crée une « Personal Team ».
  4. Sélectionner la Team dans **Signing & Capabilities** (signature automatique).
  5. Lancer une première fois depuis **Xcode (▶)** → crée le **certificat de développement**
     (impossible via `flutter run` seul, qui ne sait pas générer ce certificat).
  6. **Faire confiance** au certificat sur l'iPhone (Réglages ▸ Général ▸ VPN et gestion de l'appareil).
- **Résultat** : l'app MyPortfolio s'ouvre sur l'iPhone. Le certificat existe désormais dans le
  trousseau, donc `flutter run` fonctionnera pour les prochains lancements.
- **Limite connue** : avec un compte Apple gratuit, le profil expire après ~7 jours ; il faudra
  relancer depuis Xcode pour le renouveler.

### H.4 — « Dart VM Service was not discovered » au lancement sur l'iPhone
- **Symptôme** : `flutter run` affiche « The Dart VM Service was not discovered after 60 seconds »,
  puis, après un long délai, « Error launching application » (code 1).
- **Diagnostic** : le **build Xcode réussit** ; c'est seulement le **Mac** qui n'arrive pas à se
  **connecter** à l'app en cours d'exécution (permission « Réseau local » non accordée au terminal).
  Ce n'est donc **pas** une erreur de code.
- **Solution** : l'app est bien **installée** sur l'iPhone → il suffit de l'**ouvrir depuis son
  icône**. Pour que `flutter run` se connecte directement : autoriser « Réseau local » pour le
  terminal (Réglages système ▸ Confidentialité et sécurité ▸ Réseau local).

## I. Historique des décisions

Décisions techniques prises avec l'étudiant avant le développement. Chaque choix laisse
**ouvertes** des alternatives qui ont été écartées pour une raison précise.

### Décision 1 — Persistance locale : **sqflite**
- **Problème** : conserver les données après la fermeture de l'app (exigence du sujet).
- **Alternatives** : `sqflite` (SQL), `Hive`/`Isar` (NoSQL).
- **Choix retenu** : `sqflite`.
- **Justification** : c'est du **SQL** (tables, requêtes), notions académiques faciles à expliquer
  en soutenance ; techno la plus classique et la plus demandée.
- **Conséquence** : une couche `data` qui écrit/lit des tables SQLite.

### Décision 2 — API REST externe : **GitHub**
- **Problème** : intégrer des données d'un service externe (exigence du sujet). Aucune API imposée.
- **Alternatives** : API GitHub (dépôts), API de citations, API météo/pays…
- **Choix retenu** : **GitHub** (afficher les dépôts/projets de l'étudiant).
- **Justification** : thématiquement cohérent avec un portfolio de développeur, gratuit,
  lecture possible sans clé d'authentification.
- **Conséquence** : un écran dédié + appels `http` vers `api.github.com`.
- **Limite connue** : 60 requêtes/heure sans authentification (suffisant pour une démo).

### Décision 3 — Authentification : **non (V1)**
- **Problème** : faut-il protéger l'accès ou l'édition ?
- **Justification** : le sujet ne le demande pas ; on reste simple pour la V1. Un « mode édition »
  protégé pourra être ajouté en bonus.

### Décision 4 — Plateformes : **Android + iOS**, test prioritaire sur **Android**
- **Justification** : Flutter est multiplateforme nativement ; l'outillage Android est prêt.
- **Point ouvert** : aucun émulateur Android n'existe encore sur la machine (voir section J).

### Décision 5 — Gestion de l'état : **Provider**
- **Problème** : comment l'interface réagit-elle aux changements de données ?
- **Alternatives** : `setState` (natif, simple), `Provider`, `Bloc`/`Riverpod` (plus avancés).
- **Choix retenu** : `Provider`.
- **Justification** : bon équilibre entre code **propre/professionnel** et **simplicité**
  pour un débutant ; très enseigné.

### Décisions 6 & 7 — Ressources & contraintes professeur : **TODO**
- Les **vraies données** (parcours, projets, compétences de l'étudiant et du binôme) et les
  éventuelles **contraintes de la professeure** ne sont pas encore connues → marquées `TODO`.
- **Règle respectée** : aucune donnée métier ne sera **inventée** ; en attendant, champs vides
  ou valeurs `TODO`.

---

## J. Journal des étapes

### Étape 4 — Initialisation du projet (terminée et vérifiée)
**Objectif** : créer le squelette du projet Flutter et vérifier que tout compile.

**Commandes réellement exécutées :**
```bash
flutter doctor
flutter create --project-name myportfolio --org com.example --platforms android,ios .
flutter pub add provider sqflite path http google_fonts
flutter analyze
```

**Résultats vérifiés :**
- Projet `myportfolio` créé (plateformes Android + iOS).
- Dépendances installées : `provider 6.1.5`, `sqflite 2.4.5`, `path 1.9.1`, `http 1.6.0`,
  `google_fonts 9.0.0`.
- `flutter analyze` → **No issues found!** (0 erreur, 0 avertissement).
- `flutter doctor` → Android toolchain ✓, Chrome ✓ ; Xcode ⚠️ (avertissement) ;
  **aucun émulateur Android** (seul un simulateur iOS est disponible).

**Critère de fin atteint** : le projet compile sans erreur.
**Reste à faire** : créer un émulateur Android (ou tester sur iOS) avant de lancer l'app.

### Étape 5 — Identité visuelle (terminée et vérifiée)
**Objectif** : créer un système de design centralisé (couleurs + thème) et le brancher.

**Fichiers créés** : `lib/app/theme/app_colors.dart`, `lib/app/theme/app_theme.dart`,
`lib/app/app.dart`, `lib/app/theme/theme_showcase_page.dart`.
**Fichiers modifiés** : `lib/main.dart` (remplace l'app de démo par le lancement de notre app),
`test/widget_test.dart` (remplace le test du compteur par un test « fumée »).

**Résultats vérifiés :**
- `flutter analyze` → **No issues found!** (0 erreur, 0 avertissement).
- `flutter test` → **All tests passed!** (le test « fumée » confirme que l'app démarre).
- Une difficulté a été rencontrée et résolue (voir section H.1).

**Critère de fin atteint** : le thème est appliqué, le code compile, le test passe.
**Validation visuelle** : l'app a été lancée avec succès sur un **iPhone physique** (iOS 27) ;
l'écran vitrine affiche bien la palette Indigo/Cyan et la police Poppins. Le projet a été déplacé
vers `~/Projects/myportfolio` (voir H.2) et le déploiement iPhone est documenté en H.3.

### Étape 6 — Écrans de consultation : accueil (en cours)
**Objectif** : créer les modèles de données et l'écran d'accueil listant les 2 portfolios.

**Fichiers créés** : `lib/shared/models/{student,skill,project}.dart`,
`lib/features/portfolio/data/sample_portfolio_data.dart`,
`lib/features/portfolio/providers/portfolio_provider.dart`,
`lib/features/portfolio/presentation/pages/home_page.dart`,
`lib/features/portfolio/presentation/widgets/student_card.dart`.
**Fichiers modifiés** : `lib/app/app.dart` (ajout du `ChangeNotifierProvider`, écran de départ =
`HomePage` ; l'ancienne vitrine `theme_showcase_page.dart` n'est plus utilisée).

**Résultats vérifiés :**
- `flutter analyze` → **No issues found!**
- `flutter test` → **All tests passed!**

**Critère de fin atteint** : l'accueil liste les 2 portfolios, le code compile, le test passe,
et l'écran a été vu sur un iPhone physique.

**Mise à jour des données** : les **vraies infos du binôme (Houssain Aloulou)** ont été intégrées
depuis son CV (compétences + 3 projets académiques, sans données privées). Le champ `level` de
`Skill` est devenu **optionnel** (`int?`) pour ne pas inventer de niveaux absents du CV. Les infos
de l'étudiant 1 (Mohamed) restent `TODO`.
**Écran profil ajouté** : au toucher d'une carte, `Navigator.push` ouvre `ProfilePage`, qui affiche
la bio, les compétences (chips) et les projets (cartes), avec des **états vides** pour les sections
non renseignées. Vérifié : `flutter analyze` → 0 erreur, `flutter test` → OK.
**Reste à faire** : compléter les infos de l'étudiant 1 (Mohamed) ; puis persistance **sqflite**
(étape 8), le **CRUD**, et l'**API GitHub** (étape 9).

---

### Étape 8.1 — Fondation de la base de données (terminée et vérifiée)
**Objectif** : préparer la persistance : conversion objet ↔ SQL + création des tables.

**Fichiers créés** : `lib/core/database/app_database.dart`.
**Fichiers modifiés** : `lib/shared/models/{skill,project,student}.dart` (ajout de `toMap`/`fromMap`,
et `copyWith` pour `Student`).

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK.
**À savoir** : la base n'est pas encore *utilisée* (aucun écran ne la lit). Ce sera la sous-étape 8.2
(repository + seed). La vraie persistance ne pourra être testée qu'une fois l'app capable d'écrire.

### Étape 8.2 — Repository + seed (terminée et vérifiée)
**Objectif** : écrire la couche d'accès à la base (lecture + CRUD) et préparer le remplissage initial.

**Fichier créé** : `lib/features/portfolio/data/portfolio_repository.dart`.

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK.
**À savoir** : le repository n'est pas encore appelé (aucun écran ne l'utilise). Le branchement se
fait en 8.3 (le Provider lira la base et déclenchera le seed) ; c'est là qu'on pourra tester la
vraie persistance sur l'appareil.

### Étape 8.3 — Branchement du Provider sur la base (terminée et vérifiée)
**Objectif** : charger les données depuis la base (seed + lecture asynchrone), avec états
chargement/erreur affichés à l'écran.

**Fichiers modifiés** : `portfolio_provider.dart` (chargement async + seed + états + `try/catch`),
`home_page.dart` (indicateur de chargement + écran d'erreur « Réessayer »).

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK. Le test confirme que
l'app démarre ; comme sqflite n'existe pas dans l'environnement de test, le chargement échoue — mais
l'erreur est **bien gérée** (preuve que le `try/catch` fonctionne). La vraie persistance se teste sur
l'appareil.
**À tester sur l'iPhone** : ajouter/voir des données, fermer puis rouvrir l'app → les données doivent
être conservées.

### Étape 8.4 — CRUD des compétences (terminée et vérifiée)
**Objectif** : ajouter / modifier / supprimer une compétence depuis l'écran profil, avec persistance.

**Fichier créé** : `lib/features/portfolio/presentation/widgets/skill_form_dialog.dart`.
**Fichiers modifiés** : `portfolio_provider.dart` (addSkill/updateSkill/deleteSkill + rechargement),
`skill_chip.dart` (tappable), `profile_page.dart` (réactif via `studentId` + bouton ＋ / édition),
`home_page.dart` (passe l'`id`).

**Résultats vérifiés** : `flutter analyze` → 0 erreur (un avertissement `use_build_context_synchronously`
a été diagnostiqué et corrigé) ; `flutter test` → OK.
**À tester sur l'iPhone** : ajouter une compétence, fermer puis rouvrir l'app → elle doit être conservée.

### Étape 8.5 — CRUD des projets (terminée et vérifiée)
**Objectif** : ajouter / modifier / supprimer un projet (même schéma que les compétences).

**Fichier créé** : `lib/features/portfolio/presentation/widgets/project_form_dialog.dart`.
**Fichiers modifiés** : `portfolio_provider.dart` (CRUD projets), `project_card.dart` (tappable),
`profile_page.dart` (bouton ＋ projets + édition).

**Résultats vérifiés** : `flutter analyze` → 0 erreur (une parenthèse en trop a été introduite en
imbriquant l'`InkWell`, puis corrigée) ; `flutter test` → OK. Code reformaté avec `dart format`.
**À tester sur l'iPhone** : ajouter/modifier/supprimer un projet, puis fermer/rouvrir → conservé.

### Étape 8.6 — Édition du profil (terminée et vérifiée)
**Objectif** : modifier le nom, la filière, la bio et le pseudo GitHub d'un étudiant.

**Fichier créé** : `lib/features/portfolio/presentation/widgets/student_edit_dialog.dart`.
**Fichiers modifiés** : `portfolio_provider.dart` (`updateStudent`), `profile_page.dart` (bouton ✏️).

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK.

✅ **Étape 8 (persistance + CRUD) complète** : compétences, projets et profil sont modifiables et
conservés dans la base SQLite. Testée sur iPhone (données conservées après fermeture/réouverture).

### Étape 9.1 — Modèle + service GitHub (terminée et vérifiée)
**Objectif** : préparer l'appel à l'API GitHub (modèle d'un dépôt + service HTTP).

**Fichiers créés** : `lib/features/github/data/github_repo.dart`, `github_service.dart`.

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK.
**À savoir** : le service n'est pas encore appelé par un écran. L'affichage (un `FutureBuilder` sur
le profil) viendra en 9.2 ; c'est là qu'on testera avec un vrai pseudo GitHub.

### Étape 9.2 — Affichage des dépôts GitHub (terminée et vérifiée)
**Objectif** : afficher les dépôts publics d'un étudiant sur son profil (API REST externe).

**Fichiers créés** : `lib/features/github/presentation/widgets/github_repo_card.dart`,
`github_repos_section.dart`.
**Fichier modifié** : `profile_page.dart` (section « Dépôts GitHub » affichée si un pseudo est renseigné).

**Résultats vérifiés** : `flutter analyze` → 0 erreur ; `flutter test` → OK.

✅ **Étape 9 (API GitHub) complète.** Pour tester : renseigner un pseudo GitHub (via ✏️) → les dépôts
s'affichent. **Toutes les exigences du sujet sont désormais couvertes.**

### Étape 10 — Documentation et tests (en cours)
**Réalisé :**
- `README.md` rédigé (présentation, installation, lancement, tests, structure, limites).
- `apprentissage.md` complété (sections F « parcours d'exécution » et G « questions d'oral »).
- **Tests automatisés** ajoutés :
  - `test/models_test.dart` : modèles (`toMap`/`fromMap`, `initials`, `copyWith`, `GithubRepo.fromJson`) ;
  - `test/widgets/skill_chip_test.dart` : affichage et toucher de `SkillChip` ;
  - `test/widget_test.dart` : l'app démarre (test « fumée »).

**Résultats vérifiés** : `flutter test` → **15 tests réussis** ; `flutter analyze` → 0 erreur.
**Comment lancer** : `flutter test` (tous) ou `flutter test test/models_test.dart` (un seul fichier).

**Reste possible** : compléter les infos de l'étudiant 1 (directement dans l'app), d'éventuels tests
d'intégration, et des finitions visuelles.

### Finitions — design et fonctionnalités bonus (terminées, testées sur iPhone)
**Objectif** : moderniser le design et ajouter des fonctionnalités d'enrichissement.

**Réalisé :**
- **Thème sombre élégant** : refonte de `app_colors.dart` / `app_theme.dart` (fond anthracite,
  accent **bleu** + cyan), appliqué via `theme: AppTheme.dark`.
- **Animations** : avatar animé entre l'accueil et le profil (`Hero` dans `student_avatar.dart`),
  transition de page en fondu + glissement (`core/widgets/fade_slide_route.dart`), apparition en
  fondu des cartes d'accueil.
- **Bouton « Ajouter un CV »** : création d'un nouveau portfolio depuis l'accueil
  (`insertStudent` / `addStudent`, formulaire `student_edit_dialog.dart` réutilisé en mode création).
- **Photo de profil** : choix d'une image (galerie / appareil photo) via `image_picker`, copiée et
  conservée via `path_provider` ; nouveau champ `photoPath` (**migration base v2**) ; affichée par
  `StudentAvatar`, avec repli sur les initiales.

**Vérifié** : `flutter analyze` → 0 erreur ; `flutter test` → 15 tests OK ; thème, animations, ajout
de CV et photo (conservée après fermeture/réouverture) testés sur iPhone.

---

*Dernière mise à jour : finitions — thème sombre bleu, animations, bouton Ajouter un CV, photo de profil. Projet complet et testé sur iPhone.*
