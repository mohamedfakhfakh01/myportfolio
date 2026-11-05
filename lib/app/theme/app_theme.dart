import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thème global de MyPortfolio (Material 3, **sombre**).
///
/// Un « thème » dans Flutter, c'est l'ensemble des styles par défaut appliqués
/// automatiquement à tous les widgets : couleurs, police, forme des boutons,
/// style des champs de saisie, etc. En le centralisant ici, on garantit la
/// COHÉRENCE visuelle : tous les boutons se ressemblent, tous les champs aussi.
///
/// Classe non instanciable (constructeur privé) : on utilise `AppTheme.dark`.
class AppTheme {
  AppTheme._();

  /// Rayon d'arrondi commun (coins arrondis cohérents dans toute l'app).
  static const double _radius = 14;

  /// Construit le thème de l'application pour la luminosité demandée
  /// (clair ou sombre). Les couleurs de surface/texte sont lues depuis
  /// [AppColors], qui doit déjà avoir été basculé via
  /// `AppColors.applyBrightness(brightness)`.
  static ThemeData themeFor(Brightness brightness) {
    // Thème Material 3 de base, construit à partir d'une couleur « graine ».
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    // Typographie du design : Plus Jakarta Sans pour les titres/labels (identité
    // « tech »), Inter pour le corps de texte (lisibilité). On récupère juste
    // les noms de familles (String) via google_fonts — l'appel enregistre aussi
    // la police pour son téléchargement — pour éviter tout conflit de types.
    final String bodyFamily = GoogleFonts.inter().fontFamily!;
    final String titleFamily = GoogleFonts.plusJakartaSans().fontFamily!;

    // Base : tout en Inter, avec nos couleurs de texte.
    final TextTheme interBase = base.textTheme.apply(
      fontFamily: bodyFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    // Les titres/labels repassent en Plus Jakarta Sans.
    TextStyle? asTitle(TextStyle? style) => style?.copyWith(fontFamily: titleFamily);
    final TextTheme textTheme = interBase.copyWith(
      displayLarge: asTitle(interBase.displayLarge),
      displayMedium: asTitle(interBase.displayMedium),
      displaySmall: asTitle(interBase.displaySmall),
      headlineLarge: asTitle(interBase.headlineLarge),
      headlineMedium: asTitle(interBase.headlineMedium),
      headlineSmall: asTitle(interBase.headlineSmall),
      titleLarge: asTitle(interBase.titleLarge),
      titleMedium: asTitle(interBase.titleMedium),
      titleSmall: asTitle(interBase.titleSmall),
      labelLarge: asTitle(interBase.labelLarge),
      labelMedium: asTitle(interBase.labelMedium),
      labelSmall: asTitle(interBase.labelSmall),
    );

    // On surcharge le thème de base avec NOS choix précis.
    return base.copyWith(
      textTheme: textTheme,

      // Barre supérieure : fond sombre (surface), texte clair, sans ombre.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Boutons pleins : fond violet, texte blanc, arrondis.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          // Hauteur ≥ 48 px : zone tactile confortable (bonne UX).
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Boutons contour (action secondaire) : texte et bordure violets.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Champs de saisie : fond sombre, bordure grise, bordure violette au focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // Cartes : fond surface, coins arrondis, fine bordure + ombre douce
      // ambiante (niveau de profondeur du design Stitch). L'ombre est quasi
      // invisible en thème sombre, elle donne surtout du relief en clair.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 3,
        shadowColor: const Color(0x140F172A), // bleu nuit très transparent
        surfaceTintColor: Colors.transparent, // garde un blanc pur (M3)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius + 2),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
