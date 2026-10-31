import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/student.dart';
import 'student_avatar.dart';

/// Carte réutilisable présentant un étudiant dans la liste d'accueil.
///
/// Reçoit un [Student] à afficher et un callback [onTap] déclenché au toucher.
/// En faire un widget séparé évite de dupliquer ce code pour chaque étudiant
/// (bonne pratique : composants réutilisables).
class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      // InkWell ajoute l'effet visuel de « ondulation » au toucher.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar avec les initiales (animé en Hero vers l'écran profil).
              StudentAvatar(
                heroTag: 'avatar-${student.id}',
                initials: student.initials,
                photoPath: student.photoPath,
                radius: 26,
              ),
              const SizedBox(width: 14),
              // Nom + filière (Expanded pour occuper l'espace restant).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      student.field,
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
