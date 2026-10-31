import '../../../shared/models/student.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/project.dart';

/// Données des portfolios.
///
/// - Étudiant 2 (Houssain Aloulou) : **vraies données** issues de son CV.
/// - Étudiant 1 (Mohamed Fakhfakh) : **à compléter** (`TODO`) — l'étudiant
///   fournira ses infos plus tard.
///
/// Les niveaux de compétence (`level`) ne sont renseignés que lorsqu'ils sont
/// réellement connus ; sinon ils restent `null` (aucune valeur inventée).
/// À l'étape 8, ces données seront chargées depuis la base sqflite.
const List<Student> sampleStudents = [
  // ---------------------------------------------------------------------------
  // Étudiant 1 — À COMPLÉTER avec tes vraies infos.
  // ---------------------------------------------------------------------------
  Student(
    id: 1,
    fullName: 'Mohamed Fakhfakh',
    field: '2e année informatique',
    bio: 'TODO : à compléter (ta présentation).',
    githubUsername: null, // TODO : ton pseudo GitHub
    skills: [], // TODO : tes compétences
    projects: [], // TODO : tes projets
  ),

  // ---------------------------------------------------------------------------
  // Étudiant 2 — Houssain Aloulou (données réelles issues de son CV).
  // Coordonnées privées (téléphone, e-mail) volontairement non incluses.
  // ---------------------------------------------------------------------------
  Student(
    id: 2,
    fullName: 'Houssain Aloulou',
    field: '3e année Licence Informatique — IIT Sfax',
    bio: 'Étudiant en 3ème année de Licence en Informatique. Expérience en '
        'développement web (stage Laravel, summer camp chez Wevioo) et '
        'plusieurs projets en C#/ASP.NET, Java et PHP. Passionné de '
        'développement web et de robotique.',
    githubUsername: null, // non indiqué sur le CV
    skills: [
      Skill(name: 'C#'),
      Skill(name: 'Java'),
      Skill(name: 'PHP'),
      Skill(name: 'Python'),
      Skill(name: 'HTML / CSS'),
      Skill(name: 'ASP.NET Core / MVC'),
      Skill(name: 'Laravel'),
      Skill(name: 'Entity Framework'),
      Skill(name: 'JavaFX'),
      Skill(name: 'Bootstrap'),
      Skill(name: 'SQL Server'),
      Skill(name: 'MySQL'),
      Skill(name: 'Git'),
      Skill(name: 'OutSystems'),
      Skill(name: 'Mendix'),
    ],
    projects: [
      Project(
        title: 'EFastOrder',
        description:
            'Application web de gestion de restaurant avec commandes en ligne '
            '(C# ASP.NET Core MVC, Entity Framework, authentification avec rôles).',
      ),
      Project(
        title: 'Gestion École',
        description:
            'Application desktop de gestion scolaire et de la vie associative '
            '(Java, JavaFX, MySQL).',
      ),
      Project(
        title: 'Gestion Club',
        description:
            'Application web de gestion de club : membres, événements et '
            'activités (PHP, MySQL, Bootstrap).',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  // Étudiant 3 — PORTFOLIO DÉMO (données 100 % fictives, uniquement pour
  // tester l'affichage : graphe de répartition, barres de niveau, tri, thème).
  // Rien de réel ici — valeurs inventées de façon assumée pour la démo.
  // ---------------------------------------------------------------------------
  Student(
    id: 3,
    fullName: 'Portfolio Démo',
    field: 'Jeu de données de démonstration',
    bio: 'Profil fictif servant à tester l\'affichage : graphe des compétences, '
        'barres de niveau, tri et thème clair/sombre. Toutes les valeurs sont '
        'inventées pour la démo.',
    githubUsername: null,
    skills: [
      // Langages
      Skill(name: 'Dart', level: 85),
      Skill(name: 'Python', level: 70),
      Skill(name: 'JavaScript', level: 60),
      // Frameworks
      Skill(name: 'Flutter', level: 80),
      Skill(name: 'React', level: 55),
      // Outils
      Skill(name: 'Git', level: 75),
      Skill(name: 'Docker', level: 40),
      // Autres
      Skill(name: 'UI/UX Design', level: 50),
    ],
    projects: [
      Project(
        title: 'App Démo',
        description:
            'Projet fictif de démonstration pour tester les cartes de projet.',
      ),
      Project(
        title: 'Site Vitrine',
        description:
            'Autre projet de démo pour vérifier l\'affichage et le tri.',
      ),
    ],
  ),
];
