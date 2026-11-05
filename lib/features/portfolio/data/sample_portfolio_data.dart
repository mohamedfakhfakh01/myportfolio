import '../../../shared/models/student.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/experience.dart';

/// Données des portfolios (chargées dans la base sqflite au premier lancement).
///
/// - Étudiant 1 (Mohamed Fakhfakh) et Étudiant 2 (Houssain Aloulou) : infos
///   réelles issues de leurs CV. Les **niveaux** de compétence sont toutefois
///   indicatifs (valeurs fictives, à ajuster librement).
/// - Étudiant 3 (Portfolio Démo) : données 100 % fictives pour tester
///   l'affichage.
const List<Student> sampleStudents = [
  // ---------------------------------------------------------------------------
  // Étudiant 1 — Mohamed Fakhfakh (données réelles issues de son CV).
  // Les niveaux de compétence sont fictifs (ajoutés à la demande).
  // ---------------------------------------------------------------------------
  Student(
    id: 1,
    fullName: 'Mohamed Fakhfakh',
    field: '3e année Licence Informatique — IIT Sfax',
    bio: 'Étudiant en 3e année de Licence en Informatique, passionné par le '
        'développement web full-stack. Expérience pratique acquise en entreprise '
        'et à travers plusieurs projets concrets (e-commerce, applications de '
        'gestion, mobile). Je recherche un stage de fin d\'études (PFE) pour '
        'mettre mes compétences au service d\'une équipe et relever de nouveaux '
        'défis techniques.',
    githubUsername: 'mohamedfakhfakh01',
    email: 'fakhfakhmohamed150@gmail.com',
    phone: '+216 24 098 402',
    location: 'Sfax, Tunisie',
    skills: [
      // Langages
      Skill(name: 'Java', level: 75, category: SkillCategory.language),
      Skill(name: 'C', level: 65, category: SkillCategory.language),
      Skill(name: 'Python', level: 70, category: SkillCategory.language),
      Skill(name: 'PHP', level: 72, category: SkillCategory.language),
      Skill(name: 'C#', level: 74, category: SkillCategory.language),
      Skill(name: 'TypeScript', level: 72, category: SkillCategory.language),
      Skill(name: 'HTML5', level: 90, category: SkillCategory.language),
      Skill(name: 'CSS3', level: 88, category: SkillCategory.language),
      // Frameworks
      Skill(name: 'ASP.NET MVC', level: 72, category: SkillCategory.framework),
      Skill(
          name: 'Entity Framework', level: 68, category: SkillCategory.framework),
      Skill(name: 'JavaFX', level: 65, category: SkillCategory.framework),
      Skill(name: 'Bootstrap', level: 85, category: SkillCategory.framework),
      Skill(name: 'Flutter', level: 74, category: SkillCategory.framework),
      Skill(name: 'Next.js', level: 76, category: SkillCategory.framework),
      Skill(name: 'Tailwind CSS', level: 80, category: SkillCategory.framework),
      // Outils & bases de données
      Skill(name: 'MySQL', level: 78, category: SkillCategory.tool),
      Skill(name: 'SQL Server', level: 70, category: SkillCategory.tool),
      Skill(name: 'Prisma', level: 62, category: SkillCategory.tool),
      Skill(name: 'Git', level: 85, category: SkillCategory.tool),
      Skill(name: 'GitHub', level: 85, category: SkillCategory.tool),
    ],
    projects: [
      Project(
        title: 'Al Seniour — Restaurant',
        description:
            'Application web d\'un restaurant libanais haut de gamme (stage PFA '
            'chez Tekru Technologies) : interfaces responsives et animées, '
            'versions desktop et mobile.',
        tags: ['Next.js', 'TypeScript', 'Tailwind CSS', 'Prisma'],
      ),
      Project(
        title: 'SIBIONICS — E-commerce',
        description:
            'Site de vente en ligne avec catalogue produits, panier et gestion '
            'des commandes.',
      ),
      Project(
        title: 'Carré d\'Or — Pâtisserie',
        description:
            'Site e-commerce élégant pour une pâtisserie de luxe, design soigné '
            'et responsive.',
      ),
      Project(
        title: 'E-FastOrder',
        description:
            'Application web de gestion de commandes développée en .NET.',
        tags: ['ASP.NET MVC', 'C#', 'Entity Framework', 'SQL Server'],
      ),
      Project(
        title: 'Gestion de Club',
        description:
            'Plateforme de gestion d\'un club universitaire : membres, '
            'événements et activités.',
        tags: ['PHP', 'MySQL', 'Bootstrap'],
      ),
      Project(
        title: 'My Portfolio — Mobile',
        description:
            'Application mobile de portfolio personnel présentant mes projets '
            'et compétences.',
        tags: ['Flutter', 'Dart'],
      ),
      Project(
        title: 'Applications JavaFX',
        description:
            'Applications desktop de gestion réalisées dans le cadre de projets '
            'académiques.',
        tags: ['Java', 'JavaFX', 'MySQL'],
      ),
    ],
    experiences: [
      ExperienceEntry(
        kind: ExperienceKind.experience,
        title: 'Stagiaire Développeur Web — Projet PFA',
        organization: 'Tekru Technologies · Tunis',
        period: 'Juin – Juillet 2026',
        description:
            'Développement de l\'application web Al Seniour (restaurant libanais '
            'haut de gamme) : interfaces responsives et animées. '
            'Next.js · TypeScript · Tailwind CSS · Prisma.',
      ),
      ExperienceEntry(
        kind: ExperienceKind.education,
        title: 'Licence en Informatique (3e année)',
        organization: 'Institut International de Technologie (IIT) · Sfax',
        period: '2024 – 2027',
      ),
      ExperienceEntry(
        kind: ExperienceKind.education,
        title: 'Formation Développeur Front-End',
        organization: 'GoMyCode',
        period: '2024',
      ),
      ExperienceEntry(
        kind: ExperienceKind.education,
        title: 'Baccalauréat — Économie et Gestion',
        period: '2024',
      ),
    ],
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
      Skill(name: 'C#', level: 80, category: SkillCategory.language),
      Skill(name: 'Java', level: 75, category: SkillCategory.language),
      Skill(name: 'PHP', level: 78, category: SkillCategory.language),
      Skill(name: 'Python', level: 65, category: SkillCategory.language),
      Skill(name: 'HTML / CSS', level: 85, category: SkillCategory.language),
      Skill(
          name: 'ASP.NET Core / MVC', level: 75, category: SkillCategory.framework),
      Skill(name: 'Laravel', level: 78, category: SkillCategory.framework),
      Skill(
          name: 'Entity Framework', level: 70, category: SkillCategory.framework),
      Skill(name: 'JavaFX', level: 68, category: SkillCategory.framework),
      Skill(name: 'Bootstrap', level: 82, category: SkillCategory.framework),
      Skill(name: 'SQL Server', level: 75, category: SkillCategory.tool),
      Skill(name: 'MySQL', level: 80, category: SkillCategory.tool),
      Skill(name: 'Git', level: 80, category: SkillCategory.tool),
      Skill(name: 'OutSystems', level: 60, category: SkillCategory.tool),
      Skill(name: 'Mendix', level: 55, category: SkillCategory.tool),
    ],
    projects: [
      Project(
        title: 'EFastOrder',
        description:
            'Application web de gestion de restaurant avec commandes en ligne '
            'et authentification avec rôles.',
        tags: ['C#', 'ASP.NET Core MVC', 'Entity Framework'],
      ),
      Project(
        title: 'Gestion École',
        description:
            'Application desktop de gestion scolaire et de la vie associative.',
        tags: ['Java', 'JavaFX', 'MySQL'],
      ),
      Project(
        title: 'Gestion Club',
        description:
            'Application web de gestion de club : membres, événements et '
            'activités.',
        tags: ['PHP', 'MySQL', 'Bootstrap'],
      ),
    ],
    experiences: [
      ExperienceEntry(
        kind: ExperienceKind.experience,
        title: 'Stage — Développement web (Laravel)',
      ),
      ExperienceEntry(
        kind: ExperienceKind.experience,
        title: 'Summer camp',
        organization: 'Wevioo',
      ),
      ExperienceEntry(
        kind: ExperienceKind.education,
        title: 'Licence en Informatique (3e année)',
        organization: 'IIT · Sfax',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  // Étudiant 3 — PORTFOLIO DÉMO (données 100 % fictives, uniquement pour
  // tester l'affichage : catégories, barres de niveau, tri, thème).
  // Rien de réel ici — valeurs inventées de façon assumée pour la démo.
  // ---------------------------------------------------------------------------
  Student(
    id: 3,
    fullName: 'Portfolio Démo',
    field: 'Jeu de données de démonstration',
    bio: 'Profil fictif servant à tester l\'affichage : compétences par catégorie, '
        'barres de niveau, tri et thème clair/sombre. Toutes les valeurs sont '
        'inventées pour la démo.',
    githubUsername: null,
    skills: [
      // Langages
      Skill(name: 'Dart', level: 85, category: SkillCategory.language),
      Skill(name: 'Python', level: 70, category: SkillCategory.language),
      Skill(name: 'JavaScript', level: 60, category: SkillCategory.language),
      // Frameworks
      Skill(name: 'Flutter', level: 80, category: SkillCategory.framework),
      Skill(name: 'React', level: 55, category: SkillCategory.framework),
      // Outils
      Skill(name: 'Git', level: 75, category: SkillCategory.tool),
      Skill(name: 'Docker', level: 40, category: SkillCategory.tool),
      // Autres
      Skill(name: 'UI/UX Design', level: 50, category: SkillCategory.other),
    ],
    projects: [
      Project(
        title: 'App Démo',
        description:
            'Projet fictif de démonstration pour tester les cartes de projet.',
        link: 'https://github.com/mohamedfakhfakh01/myportfolio',
        tags: ['Flutter', 'Dart', 'SQLite'],
      ),
      Project(
        title: 'Site Vitrine',
        description:
            'Autre projet de démo pour vérifier l\'affichage et le tri.',
        link: 'https://flutter.dev',
        tags: ['HTML', 'CSS', 'JavaScript'],
      ),
    ],
  ),
];
