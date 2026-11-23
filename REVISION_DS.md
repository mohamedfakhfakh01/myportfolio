# Fiche de révision — DS Développement mobile (MyPortfolio)

> Pour **Mohamed et Houssain**. Le barème donne **3 points** à « Questions / réponses
> individuelles » : la prof vérifie que **chacun** comprend le code. Ne récitez pas cette fiche :
> pour chaque réponse, **ouvrez le fichier indiqué** et redites-la avec vos mots.
> Si vous ne savez pas, dites ce que vous feriez pour trouver (lire le fichier, lancer le test) :
> c'est mieux qu'inventer.

---

## 1. La démo en 3 minutes (un critère du barème à chaque étape)

| # | Je fais… | Je dis… | Critère |
|---|---|---|---|
| 1 | J'ouvre l'app | « L'accueil liste les **deux portfolios**, Mohamed et Houssain. » | Structure (2) |
| 2 | Je touche Mohamed | « Route nommée `/profil` : identité, filière, bio, contact, compétences, projets, expérience, formation. » | Navigation (2) + Informations (2) |
| 3 | Je touche un projet, puis ← | « Route `/projet` ; le retour revient au profil. » | Navigation |
| 4 | « Ajouter un CV », je remplis nom + filière, « Créer » | « **C**reate : le portfolio apparaît dans la liste. » | CRUD (3) |
| 5 | Je modifie (crayon) puis j'enregistre | « **U**pdate, avec validation des champs. » | CRUD |
| 6 | Corbeille → confirmation → Supprimer | « **D**elete, avec confirmation avant l'action destructive. » | CRUD |
| 7 | Je **ferme complètement l'app** et je la rouvre | « Les données sont restées : elles sont dans une **base SQLite** sur le téléphone. » | Persistance (2) |
| 8 | Profil de Mohamed → « Dépôts GitHub » | « Appel à l'**API REST GitHub** : chargement, affichage, gestion d'erreur. » | API REST (2) |
| 9 | Mode avion, puis « Réessayer » | « Hors ligne, un message clair et un bouton Réessayer, pas un plantage. » | API REST |

---

## 2. Une fonctionnalité de bout en bout : « je touche *Créer le portfolio* »

C'est LA question classique (« expliquez une fonctionnalité »). Suivez le fil, fichier par fichier :

1. **Le bouton** — `lib/features/portfolio/presentation/pages/student_form_page.dart`, méthode
   `_save()` : elle met `_saving = true` (le bouton se désactive → pas de double appui = pas de
   doublon), puis appelle `_doSave()`.
2. **La validation** — `_doSave()` commence par `_formKey.currentState!.validate()` : chaque
   `TextFormField` a un `validator` (nom obligatoire, nom déjà pris, e-mail mal formé…). Si un
   champ est faux, on s'arrête et le message s'affiche sous le champ.
3. **GitHub** — si un pseudo est saisi, `GithubService.checkUser` demande à l'API si le compte
   existe (inconnu → erreur sous le champ ; hors ligne → on enregistre quand même, avec un
   avertissement).
4. **Le modèle** — on construit un objet `Student` (`lib/shared/models/student.dart`) avec les
   valeurs des `TextEditingController`.
5. **Le provider** — `provider.addStudent(student, …)`
   (`lib/features/portfolio/providers/portfolio_provider.dart`) : il revérifie qu'aucun portfolio
   ne porte déjà ce nom, puis délègue au repository.
6. **La base** — `PortfolioRepository.insertStudent`
   (`lib/features/portfolio/data/portfolio_repository.dart`) : `student.toMap()` transforme l'objet
   en ligne de table, puis `db.insert('students', …)` l'écrit dans SQLite.
7. **Le rechargement** — le provider relit la liste depuis la base, puis appelle
   `notifyListeners()`.
8. **L'écran se met à jour** — l'accueil fait `context.watch<PortfolioProvider>()` : il est
   prévenu et se redessine avec le nouveau portfolio. Le formulaire fait `Navigator.pop` et une
   `SnackBar` confirme « Portfolio enregistré ».

> Analogie : le formulaire est le **serveur** au restaurant (il prend la commande et vérifie
> qu'elle est complète), le provider est le **chef de rang** (il fait respecter les règles), le
> repository est la **cuisine** (il parle à la base), et `notifyListeners()` c'est la cloche qui
> prévient la salle que le plat est prêt.

---

## 3. Questions Flutter probables (réponse courte + où le montrer)

**StatelessWidget ou StatefulWidget ?**
Stateless = il affiche ce qu'on lui donne, il n'a rien qui change en lui (ex. `StudentCard`,
`lib/features/portfolio/presentation/widgets/student_card.dart`). Stateful = il garde un **état**
qui change et se redessine (ex. `MainShell`, `lib/app/main_shell.dart` : l'onglet choisi `_index`).

**À quoi sert `setState` ?**
À modifier l'état **et** prévenir Flutter qu'il doit redessiner le widget. Exemple : dans
`main_shell.dart`, `onSelected: (i) => setState(() => _index = i)` change d'onglet. Sans `setState`,
la variable change mais l'écran ne bouge pas.

**Qu'est-ce que la méthode `build` ?**
Elle décrit l'écran à partir de l'état actuel ; Flutter l'appelle à chaque redessin. Elle doit
être rapide et ne rien enregistrer.

**Qu'est-ce que le `BuildContext` ?**
La position du widget dans l'arbre. On s'en sert pour trouver ce qui est « au-dessus » :
le thème (`Theme.of(context)`), les traductions, le provider, le `Navigator`.

**Pourquoi Provider ? `watch` ou `read` ?**
Le `PortfolioProvider` (un `ChangeNotifier`) contient la liste des portfolios et est partagé par
tous les écrans (créé dans `lib/app/app.dart` avec `MultiProvider`). `context.watch` = « je veux
être redessiné quand ça change » (dans `build`) ; `context.read` = « je veux juste appeler une
action » (dans un `onPressed`, ex. supprimer).

**`Future`, `async`, `await` ?**
Une opération longue (base de données, réseau) renvoie un `Future` : une promesse de résultat.
`await` attend le résultat **sans bloquer l'écran** ; une fonction qui utilise `await` est
`async`. Exemple : `load()` dans le provider attend `_repository.getStudents()`.

**`FutureBuilder` ?**
Il affiche un `Future` selon son état : en cours → roue de chargement ; erreur → message +
« Réessayer » ; terminé → les données. Exemple : `github_repos_section.dart`. La requête est
créée **une seule fois** dans `initState` (pas dans `build`, sinon on rappellerait l'API à chaque
redessin).

**La navigation ? Les routes ?**
Toutes les routes nommées sont déclarées dans **`lib/app/app_routes.dart`** : `/` (accueil),
`/profil`, `/projet`, `/portfolio/nouveau`, `/portfolio/modifier`. On y va avec
`Navigator.of(context).pushNamed(AppRoutes.profil, arguments: id)` ; on revient avec
`Navigator.pop`. Le `Navigator` est une **pile** : `push` empile un écran, `pop` le retire.
`onGenerateRoute` vérifie l'argument (`case profil when args is int`) : un mauvais argument ou
une adresse inconnue mène à « Page introuvable » au lieu de planter.

**Les formulaires ?**
Un `Form` avec une `GlobalKey<FormState>` ; chaque `TextFormField` a un `validator` qui renvoie
`null` (OK) ou un message d'erreur. `_formKey.currentState!.validate()` les vérifie tous.

**`TextEditingController` et `dispose` ?**
Le contrôleur contient le texte d'un champ. Il réserve des ressources : on le libère dans
`dispose()` quand l'écran disparaît (voir `student_form_page.dart`), sinon fuite de mémoire.

**Comment les données sont-elles conservées ?**
Base **SQLite** via le paquet `sqflite` (`lib/core/database/app_database.dart`) : un fichier
`myportfolio.db` sur le téléphone, 4 tables (`students`, `skills`, `projects`, `experiences`).
Il survit à la fermeture de l'app. `toMap()` / `fromMap()` (dans les modèles) convertissent un
objet Dart ↔ une ligne de table.

**C'est quoi `version` et `onUpgrade` dans la base ?**
La base est en **version 7**. Quand on ajoute une colonne, on augmente la version et on écrit le
changement dans `onUpgrade` : une app déjà installée met sa base à jour **sans perdre les
données** (une migration).

**L'API REST ?**
`lib/features/github/data/github_service.dart` : requête HTTP `GET` vers
`https://api.github.com/users/<pseudo>/repos`, réponse en **JSON** convertie en objets
`GithubRepo` (`fromJson`). Selon le **code HTTP** : 200 = OK, 404 = compte introuvable,
403 = limite de requêtes atteinte. Un délai maximal (`timeout`) évite d'attendre indéfiniment.

**Pourquoi `const` devant certains widgets ?**
Le widget est construit une seule fois, à la compilation, et réutilisé : Flutter n'a pas à le
recréer à chaque redessin. C'est une petite optimisation.

**Hot reload ou hot restart ?**
Hot reload : recharge le code en gardant l'état (l'écran reste où il est). Hot restart :
relance l'app à zéro (l'état est perdu, pas la base de données).

**Le `pubspec.yaml` ?**
La carte d'identité du projet : nom, version, **dépendances** (provider, sqflite, http…).
`flutter pub get` les télécharge.

---

## 4. Questions sur NOS choix (la prof aime le « pourquoi »)

- **Pourquoi un repository entre le provider et la base ?** Pour séparer « les règles » (provider)
  de « comment on stocke » (repository). En test, on remplace la vraie base par un **faux dépôt
  en mémoire** : les tests sont rapides et ne touchent pas le téléphone.
- **Pourquoi le provider recharge depuis la base après chaque écriture ?** Pour que l'écran
  affiche **toujours** ce qui est vraiment enregistré, jamais une supposition.
- **Comment empêchez-vous les doublons ?** Trois barrières : le `validator` du nom, le provider
  qui refuse (`nameExists`), et le bouton désactivé pendant l'enregistrement (double appui).
- **Que se passe-t-il sans internet ?** Tout fonctionne (les données sont locales) sauf GitHub,
  qui affiche un message et « Réessayer ».
- **Comment savez-vous que ça marche ?** **220 tests automatiques** (`flutter test`), relancés par
  GitHub à chaque envoi de code (la CI, `.github/workflows/ci.yml`).
- **Comment le code est-il organisé ?** Par fonctionnalité (`lib/features/portfolio`,
  `lib/features/github`), et dans chacune : `data/` (stockage, API), `providers/` (état),
  `presentation/pages/` (écrans), `presentation/widgets/` (morceaux réutilisables),
  `domain/` (logique pure, ex. le calcul du % de complétion).

---

## 5. À s'entraîner à voix haute (5 minutes chacun)

1. Ouvrir `lib/app/app_routes.dart` et expliquer comment on va de l'accueil au profil.
2. Ouvrir `github_repos_section.dart` et expliquer les 3 états du `FutureBuilder`.
3. Ouvrir `portfolio_provider.dart` et expliquer `addStudent` puis `notifyListeners`.
4. Ouvrir `app_database.dart` et dire où sont créées les tables et pourquoi il y a une version.
5. Expliquer la différence entre `StudentCard` (Stateless) et `MainShell` (Stateful).

---

## 6. La veille du DS

- [ ] iPhone **chargé**, app à jour (dernière version installée), les deux portfolios présents.
- [ ] Tester une fois : fermer complètement l'app et la rouvrir (persistance).
- [ ] Tester le mode avion sur la section GitHub (gestion d'erreur).
- [ ] Le projet ouvert sur le Mac (VS Code), prêt à montrer un fichier.
- [ ] `flutter test` lancé une fois : tout est vert.
