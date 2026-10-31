import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app_colors.dart';

/// Gère le thème (clair/sombre) de l'application et **mémorise** le choix.
///
/// C'est un [ChangeNotifier] : quand la luminosité change, il prévient ses
/// écouteurs (le [MaterialApp]) qui se reconstruisent avec le bon thème.
/// Le choix est enregistré dans un petit fichier du dossier de l'app
/// (via `path_provider`, déjà utilisé pour les photos) : pas de nouveau paquet.
class ThemeController extends ChangeNotifier {
  Brightness _brightness = Brightness.dark;

  /// Luminosité actuelle (sombre par défaut).
  Brightness get brightness => _brightness;

  /// Vrai si le thème sombre est actif.
  bool get isDark => _brightness == Brightness.dark;

  ThemeController() {
    // La palette globale doit correspondre dès le premier rendu.
    AppColors.applyBrightness(_brightness);
    _load();
  }

  /// Bascule entre clair et sombre, applique la palette et enregistre le choix.
  Future<void> toggle() async {
    _brightness = isDark ? Brightness.light : Brightness.dark;
    AppColors.applyBrightness(_brightness);
    notifyListeners();
    await _save();
  }

  Future<File> _prefFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/theme_preference.txt');
  }

  /// Charge le choix enregistré (le cas échéant) au démarrage.
  Future<void> _load() async {
    try {
      final File file = await _prefFile();
      if (!await file.exists()) return;
      final String value = (await file.readAsString()).trim();
      _brightness = value == 'light' ? Brightness.light : Brightness.dark;
      AppColors.applyBrightness(_brightness);
      notifyListeners();
    } catch (_) {
      // En cas d'échec (ex : environnement de test sans stockage), on garde
      // le thème par défaut : l'app reste utilisable.
    }
  }

  Future<void> _save() async {
    try {
      final File file = await _prefFile();
      await file.writeAsString(isDark ? 'dark' : 'light');
    } catch (_) {
      // Échec d'écriture non bloquant : le thème reste appliqué pour la session.
    }
  }
}
