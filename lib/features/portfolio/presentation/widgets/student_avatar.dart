import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Avatar circulaire d'un étudiant, réutilisable.
///
/// - Si [photoPath] pointe vers un fichier image existant → on affiche la photo.
/// - Sinon → on affiche les [initials] sur un fond coloré.
///
/// Il est enveloppé dans un [Hero] : lors de la navigation accueil → profil,
/// Flutter **anime** l'avatar d'un écran à l'autre (même `heroTag` des 2 côtés).
/// Un fin anneau blanc l'entoure pour qu'il ressorte sur fond clair comme sur
/// l'en-tête coloré.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.heroTag,
    required this.initials,
    this.photoPath,
    this.radius = 26,
  });

  final Object heroTag;
  final String initials;
  final String? photoPath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // La photo n'est utilisée que si le fichier existe réellement.
    final bool hasPhoto =
        photoPath != null && File(photoPath!).existsSync();

    return Hero(
      tag: heroTag,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          backgroundImage: hasPhoto ? FileImage(File(photoPath!)) : null,
          child: hasPhoto
              ? null
              : Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: radius * 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}
