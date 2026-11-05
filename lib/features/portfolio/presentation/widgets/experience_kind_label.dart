import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/experience.dart';

/// Libellé **traduit** d'un type d'entrée de parcours (expérience / formation).
String experienceKindLabel(AppLocalizations l, ExperienceKind kind) =>
    kind == ExperienceKind.education ? l.educationTitle : l.experienceTitle;
