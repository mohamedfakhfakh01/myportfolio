# CLAUDE.md — MyPortfolio

> Faits propres à ce projet. La **méthode de travail** (comment travailler, definition of done)
> vit dans `~/.claude/CLAUDE.md`, chargé automatiquement à chaque session : elle n'est pas
> recopiée ici pour éviter deux sources de vérité qui divergent.

---

## 1. Vue d'ensemble

**Projet :** application mobile Flutter de portfolio étudiant (module *Développement Mobile*).
**Objectif :** permettre à un étudiant de constituer son portfolio (profil, compétences, projets,
parcours) et de le montrer à un recruteur, hors ligne, depuis son téléphone.
**Périmètre réel :** plusieurs portfolios, CRUD complet, tableau de bord avec score de complétion,
export PDF, dépôts GitHub, thèmes clair/sombre, FR/EN. **Pas de sauvegarde** des données.
**Stack :** Flutter 3.47 / Dart 3.13 · Material 3 · Provider · sqflite · API GitHub.
**Cible testée :** **iOS** (simulateur + iPhone physique). Android : **compile** (APK release),
mais jamais lancé sur appareil ni émulateur.

---

## 2. Sources de données autorisées

> Règle absolue : aucune donnée métier inventée.

| Source | Utilisée pour |
|---|---|
| `CV_Mohamed_Fakhfakh.pdf` (fourni par l'utilisateur) | Profil, projets, parcours de Mohamed |
| Saisie de l'utilisateur dans l'app | Tout le reste |
| API GitHub publique | Dépôts affichés sur le profil |

⚠️ **Exception explicitement demandée** : les **niveaux de compétence** (pourcentages) de Mohamed
et de Houssain sont **fictifs** — l'utilisateur les a demandés ainsi pour la démonstration. Ne pas
les présenter comme des données réelles, et ne pas « corriger » leur présence.

Le portfolio fictif **« Portfolio Démo »** a été **retiré le 19 nov. 2026** (à la demande) : il n'est
plus créé ni recréé au démarrage (`ensureDemoStudent` supprimé). Une base existante qui le contient
encore le garde jusqu'à ce que l'utilisateur le supprime (corbeille) ; il ne revient plus ensuite.

**Sources uniques de vérité dans le code :**
- `lib/app/theme/app_colors.dart` → toutes les couleurs, **y compris celles du PDF**
- `lib/l10n/app_fr.arb` (modèle) + `app_en.arb` → tous les textes affichés
- `lib/features/portfolio/data/sample_portfolio_data.dart` → données d'amorçage
- `lib/shared/widgets/` → composants réutilisables (pilules, feuilles de formulaire)
- `lib/shared/utils/` → règles de saisie partagées : `linkedin.dart` (pseudo → URL, écran **et**
  PDF), `github.dart` (adresse collée → pseudo), `email.dart` (forme d'une adresse)

---

## 3. Commandes essentielles

```bash
export PATH="$HOME/flutter/bin:$PATH"      # Flutter n'est PAS dans le PATH
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 # obligatoire avant tout build iOS

flutter analyze                             # 0 erreur attendu
flutter test                                # 176 tests
flutter gen-l10n                            # APRÈS toute modif des .arb
flutter run -d 87E626E0-E743-44A6-8A48-AA716FD7851B --debug   # simulateur iPhone 18 Pro Max
flutter build ios --release                 # puis: flutter install -d <udid> --release
flutter build apk --release                 # APK Android (signé clé debug)
```

**Appareils :** simulateur `87E626E0-E743-44A6-8A48-AA716FD7851B` ·
iPhone physique « iPhone de fakh » `00008120-000664510C70201E`.

---

## 4. Pièges connus

> La section la plus rentable du fichier. À compléter à chaque bug non trivial.

1. **`pod install` plante sans locale UTF-8** (Ruby 4.0) :
   `Unicode Normalization not appropriate for ASCII-8BIT`. Toujours exporter `LANG`/`LC_ALL`.
2. **Flutter absent du `PATH`** → utiliser `~/flutter/bin/flutter`.
3. **Le paquet `material_ui` définit son propre `TextTheme`**, incompatible avec celui de Flutter :
   `GoogleFonts.*TextTheme()` ne compile pas. Passer par le **nom de police**
   (`GoogleFonts.inter().fontFamily`, une `String`).
4. **`LinearProgressIndicator` n'accepte pas de dégradé** : barre custom (piste + `LinearGradient`).
5. **`flutter install` ne recompile pas toujours** : vérifier la date de
   `build/ios/iphoneos/Runner.app`, sinon forcer `flutter build ios --release` avant.
6. **Réinstaller l'app efface sa base** (« Uninstalling old version… ») et il n'existe **aucune
   sauvegarde**. Pour mettre à jour l'iPhone, toujours installer **par-dessus** :
   `xcrun devicectl device install app --device <udid> build/ios/iphoneos/Runner.app`
   (jamais `flutter install`, qui désinstalle d'abord).
7. **`flutter run` peut échouer** sur `The log reader failed unexpectedly` : l'app Simulator
   (interface) n'est pas installée dans cet Xcode. **Relancer** suffit en général.
8. **Toute modif des `.arb` exige `flutter gen-l10n`**, sinon le getter n'existe pas.
9. **Changement de schéma = incrémenter `AppDatabase.latestVersion` + ajouter un bloc `onUpgrade`**,
   sinon les bases existantes ne migrent pas.
10. **Premier build Android très long et fragile** : la 1re tentative a échoué après **46 min**
    sur un téléchargement Gradle ; la relance automatique a réussi en ~2 min (cache rempli).
    En cas d'échec réseau, relancer avant de chercher plus loin.
11. **Un formulaire dans une `ListView` ne valide pas les champs hors écran** : la `ListView`
    détruit les champs qui sortent de l'écran, qui quittent alors le `Form`, et `validate()`
    les ignore. Bug réel corrigé : on pouvait créer un portfolio **sans nom** en faisant défiler
    avant de valider. Tout formulaire → `SingleChildScrollView` + `Column`.
12. **En test de widget, un champ qui garde le focus ramène la vue vers lui** et annule
    `ensureVisible` : appeler `FocusManager.instance.primaryFocus?.unfocus()` avant de défiler.
13. **Ne pas lancer `dart format` sur tout un fichier** pour corriger une indentation locale : le
    projet n'est pas formaté partout, le diff devient illisible.
14. **`showModalBottomSheet` est bloqué par défaut à 9/16 de l'écran** : un contenu de longueur
    variable dans une `Column` fixe **déborde** (cas réel : feuille de complétion d'un portfolio
    neuf, 11 critères : 167 px coupés, mesurés en test à la taille 440×956 de l'iPhone 18 Pro Max). → `isScrollControlled: true` +
    `useSafeArea: true` + contenu dans un `SingleChildScrollView`.
15. **Tester un écran sur une taille de téléphone** (`tester.view.physicalSize`) : la taille par
    défaut des tests (800×600, paysage) cache les débordements verticaux.
16. **La police standard du PDF ne dessine que le Latin-1 (codes 0–255)** et la bibliothèque `pdf`
    **saute sans erreur** tout autre caractère (avertissement en debug seulement). Tout texte
    utilisateur passe par `pdfSafeText` (fait une fois à l'entrée de `buildPortfolioPdf`).
17. **`MultiPage` (pdf) ne coupe une page qu'entre deux blocs de premier niveau** : un gros bloc
    (ex. 20 compétences dans une `Column`) est poussé **en entier** à la page suivante → page à
    moitié vide et titre orphelin. Garder le contenu **à plat** (`_section` : un bloc par élément,
    titre attaché au premier). Tester le texte : `buildPortfolioPdf(..., compress: false)` puis
    lire les `[(mot)]TJ` ; la mise en page, elle, se vérifie à l'œil (PDF → PNG avec `sips`).
18. **`AppColors.textPrimary`, `border`, `surface`… changent avec le thème** (sombre = texte presque
    blanc). Le PDF, imprimé sur papier blanc, doit lire les constantes **`…Light`**
    (`AppColors.textPrimaryLight`…), sinon un export en thème sombre serait blanc sur blanc.
19. **Le provider ne fabrique pas de texte affiché** : il expose un état (`hasError`), l'écran
    choisit le message dans les `.arb`. Un texte en dur dans la logique échappe à la traduction
    (cas réel : l'erreur de chargement restait en français dans l'app en anglais).
20. **Un enregistrement asynchrone + double appui = doublon.** Les 4 formulaires créaient deux fois
    la même chose, et deux portfolios du même nom (l'anti-doublon voyait la liste pas encore à
    jour). Parades : drapeau `_saving` (bouton désactivé pendant `_doSave`) **et**, côté provider,
    les noms en cours de création sont « réservés » (`_pendingNames`). Tout nouveau formulaire
    reprend ce schéma. En test, un faux dépôt **qui prend du temps** est nécessaire pour reproduire.
21. **Boutons d'une feuille : `OverflowBar`, jamais `Row`.** Trois boutons (Supprimer / Annuler /
    Enregistrer) débordaient sur 360 px et « Enregistrer » sortait de l'écran.
22. **Faux dépôt partagé pour les tests d'écrans** : `test/helpers/fake_portfolio_repository.dart`
    (CRUD complet, écritures lentes, compteur `writes`). Les anciens tests gardent leur propre faux.
23. **Le pseudo GitHub construit une URL** (`api.github.com/users/<pseudo>/repos`) : une adresse
    collée en entier la casse. Toute saisie passe par `githubUsernameFrom` avant d'être enregistrée.
24. **Le formulaire de CV appelle GitHub** (`GithubService.checkUser`, `GET /users/<pseudo>`) avant
    d'enregistrer un pseudo **nouveau ou modifié** : 404 → erreur sous le champ, rien n'est créé ;
    hors ligne / 403 / délai → enregistré quand même + avertissement. Le service est **injectable**
    (`StudentFormPage(githubService:)`) : en test, toujours un `MockClient`, jamais le réseau.
25. **En test, un message d'erreur de champ disparaît en fondu** : après correction, un seul `pump()`
    le trouve encore ; il faut `pumpAndSettle()`. (Fausse alerte rencontrée, pas un bug.)
26. **Aperçu GitHub pendant la saisie** : requête lancée **700 ms après la dernière touche**
    (`Timer`, annulé dans `dispose`) pour ménager la limite de 60 requêtes/h ; une réponse arrivée
    après un changement de pseudo est **ignorée** (`_previewUser != pseudo`). En test :
    `pump(700 ms)` puis `pumpAndSettle()`. Un compte trouvé par l'aperçu n'est pas revérifié à
    l'enregistrement.
27. **Icône et écran de démarrage = fichiers générés**, hors de l'app : `dart run
    tool/generate_icon.dart` → `dart run flutter_launcher_icons` → `dart run
    flutter_native_splash:create`. Le script et le `pubspec` recopient les couleurs de
    `app_colors.dart` (le script ne peut pas l'importer : pas de Flutter sous `dart run`) ;
    `test/brand_colors_test.dart` vérifie qu'ils restent identiques. `flutter_native_splash`
    **réindente `ios/Runner/Info.plist`** sans rien changer : `git checkout` ce fichier.
28. **iOS garde l'ancienne icône en cache** après une mise à jour : le simulateur a montré l'icône
    bleue jusqu'au redémarrage (`simctl shutdown` + `boot`). Sur iPhone : redémarrer le téléphone.

---

## 5. Design system (indigo/violet)

| Token | Valeur | Usage |
|---|---|---|
| Primaire | `#4F46E5` | boutons, icônes, onglet actif |
| Indigo « texte » | `#4F46E5` / `#A5B4FC` | `AppColors.primaryText` : lien ou titre indigo posé sur le fond (contraste ≥ 4,5:1 dans les 2 thèmes) |
| Violet | `#7C3AED` | fin des dégradés |
| Fond clair / sombre | `#F7F8FC` / `#0F172A` | |
| Surface | `#FFFFFF` / `#1E293B` | cartes |
| Texte principal / secondaire | `#0F172A` / `#64748B` | |
| Bordure | `#E2E8F0` / `#334155` | |
| Police titres / corps | Plus Jakarta Sans / Inter | |
| Rayons | 14–18 cartes · 24 feuilles · 999 pilules | |

**Thème clair par défaut** ; le sombre reste disponible et mémorisé.
Les dégradés vont systématiquement **primaire → violet**.

---

## 6. Architecture

```
lib/
├── main.dart
├── app/                     # racine, thème, nav flottante, À propos, Réglages
├── core/                    # database/ (schéma + migrations), widgets/ (transitions)
├── shared/
│   ├── models/              # Student, Skill, Project, ExperienceEntry
│   ├── utils/               # linkedin, github, email : règles de saisie partagées
│   └── widgets/             # PillTag, FormSheetBody (composants partagés)
└── features/
    ├── portfolio/
    │   ├── data/            # PortfolioRepository + données d'amorçage
    │   ├── domain/          # profile_completion.dart (logique pure)
    │   ├── providers/       # PortfolioProvider (ChangeNotifier)
    │   ├── presentation/    # pages/ et widgets/
    │   └── services/        # portfolio_pdf.dart
    └── github/              # modèle, service, widgets
```

**Décisions structurantes :**
- Architecture **feature-first** ; `domain/` contient la logique **pure et testable**
  (complétion du profil) séparée de l'interface.
- Le `PortfolioProvider` **recharge depuis la base** après chaque écriture : l'UI ne devine jamais
  l'état, elle le relit.
- Le repository est **injectable** dans le provider → tests avec un faux dépôt en mémoire.
- Les callbacks de schéma d'`AppDatabase` sont **statiques et publics** pour être rejoués en test.

---

## 7. Flux métier

**Créer un portfolio** : accueil → « Ajouter un CV » → formulaire (profil, contact, compétences,
projets, parcours saisis en feuilles) → `addStudent` insère l'étudiant puis son contenu → retour liste.
**Aucun doublon de nom** (création et renommage ; casse et espaces ignorés) : le formulaire
affiche l'erreur sous le champ, et le provider refuse aussi (`DuplicatePortfolioNameException`)
pour qu'aucun chemin ne contourne la règle.

**Complétion du profil** : `profileCompletion(student)` évalue **11 critères** (photo, bio, e-mail,
téléphone, LinkedIn, localisation, GitHub, ≥1 compétence, ≥1 projet, ≥1 expérience, ≥1 formation)
→ anneau + liste des manquants au toucher.

---

## 8. Sécurité et dettes assumées

Application **100 % locale** : pas de serveur, pas d'authentification, pas de secret. Les règles de
validation côté serveur ne s'appliquent pas ici.

- ✅ Données persistées localement, migrations testées (aucune perte à la mise à jour).
- ⚠️ **Aucune sauvegarde** : l'export/import JSON a été **retiré le 19 nov. 2026** à la demande
  de l'utilisateur. Les données ne vivent que sur l'appareil (récupérable via git : `638721f`).
- ⚠️ **Android compilé mais jamais exécuté** ; APK signé avec la **clé de debug**
  (`android/app/build.gradle.kts`), donc non publiable sur le Play Store.
- ⚠️ Couverture de tests ≈ 78 % (des fichiers chargés par les tests) : logique, accueil (98 %),
  profil (82 %), PDF (97 %), détail projet (79 %), formulaires (75–95 %, création de CV 90 %).
  Restent hors tests : choix de photo (`image_picker`), ouverture de liens (`url_launcher`).
- ⚠️ **PDF en Helvetica (Latin-1 seulement)** : la ponctuation typographique est remplacée par
  `pdfSafeText` (« — » → « - », « ’ » → « ' », « œ » → « oe »…). Les **émoji et écritures non
  latines (arabe…) sont retirés** du PDF : il faudrait embarquer une police Unicode pour les garder.
- ⚠️ CocoaPods au lieu de Swift Package Manager (builds plus lents, piège de la locale).

---

## 9. Base de données (SQLite, version 7)

| Table | Champs clés | Notes |
|---|---|---|
| `students` | fullName, field, bio, githubUsername, photoPath, email, phone, linkedin, location | |
| `skills` | studentId, name, level (0–100, nullable), category | `ON DELETE CASCADE` |
| `projects` | studentId, title, description, link, imagePath, **tags** | `tags` = liste **JSON** |
| `experiences` | studentId, title, organization, period, description, kind | kind = experience / education |

**Historique des migrations :** v2 photoPath · v3 category · v4 table experiences ·
v5 champs contact · v6 imagePath · v7 tags.

---

## 10. Variables d'environnement

Aucune : l'application ne contacte que l'API GitHub publique, sans clé.

---

## 11. À faire

- [ ] **Lancer l'APK Android** sur un émulateur ou un appareil (aucun AVD sur cette machine).
- [ ] Configurer une **signature release** Android avant toute publication.
- [ ] Migrer CocoaPods → Swift Package Manager.

---

## 12. Journal des phases

| Phase | Date | Résumé |
|---|---|---|
| 1–10 | 2026 | Fondations : modèles, base, CRUD, GitHub, tests, documentation |
| Finitions | oct. 2026 | Thème sombre, animations, photo de profil, ajout de CV |
| Enrichissement | nov. 2026 | Contact, parcours, images de projet, CI, icône/splash |
| Design | nov. 2026 | Typographie, palette indigo/violet, thème clair, nav flottante, tableau de bord |
| Données | 18 nov. 2026 | Technologies par projet (v7), écran détail, filtre, sauvegarde JSON |
| Retrait | 19 nov. 2026 | Sauvegarde JSON retirée (à la demande) ; anti-doublon à la création conservé |
| Tests écrans | 19 nov. 2026 | Tests page profil + PDF (78 tests, ≈ 50 %) ; débordement de la feuille de complétion corrigé ; perte des « — » dans le PDF découverte |
| PDF | 19 nov. 2026 | `pdfSafeText` : ponctuation typographique remplacée, plus aucun caractère perdu (81 tests) |
| CV complet | 19 nov. 2026 | PDF : coordonnées (liens cliquables), expérience, formation ; pagination corrigée (89 tests) |
| Couleurs PDF | 19 nov. 2026 | PDF aux couleurs de l'app (indigo → violet), lues dans `app_colors.dart`, indépendantes du thème (91 tests) |
| Ménage | 19 nov. 2026 | Code mort retiré (vitrine du thème, `SkillChip`), paquet `cupertino_icons` inutilisé retiré ; `flutter clean` : 5,2 Go → 150 Mo (88 tests) |
| Tests accueil | 19 nov. 2026 | 12 tests (recherche, suppression, états) ; message d'erreur traduit (il était en dur en français) ; en-têtes du formulaire de création qui débordaient (100 tests, ≈ 56 %) |
| Tests formulaires | 19 nov. 2026 | Détail projet + feuilles : double appui (doublons, dont 2 portfolios du même nom), technos en double, boutons qui débordent — corrigés (123 tests, ≈ 70 %) |
| Retrait Démo | 19 nov. 2026 | Portfolio Démo retiré du code : il était recréé à chaque démarrage, donc impossible à supprimer |
| Tests création CV | 19 nov. 2026 | Formulaire de CV testé (42 → 90 %) ; pseudo GitHub normalisé, e-mail vérifié (143 tests, ≈ 78 %) |
| Compte GitHub | 19 nov. 2026 | À la création / modification d'un CV, l'app vérifie auprès de GitHub que le compte existe (159 tests, ≈ 78 %) |
| Aperçu GitHub | 19 nov. 2026 | Pendant la saisie du pseudo, les derniers dépôts publics s'affichent sous le champ ; vérifié sur simulateur avec le vrai GitHub (170 tests, ≈ 78 %) |
| Icône & démarrage | 19 nov. 2026 | Icône en dégradé indigo → violet, écran de démarrage indigo (fin de l'ancien bleu) ; couleurs gardées par un test (174 tests) |
| Lien photo | 20 nov. 2026 | « Ajouter une photo » lisible en thème sombre (contraste 2,8 → 9:1) via `AppColors.primaryText` (176 tests) |

---

## 13. Collaboration

- Commits : `type: résumé en français` (`feat` / `fix` / `chore` / `refactor` / `test`).
- Binôme : Mohamed Fakhfakh et Houssain Aloulou.
- Changement de schéma = **migration versionnée** (jamais de recréation de table).
