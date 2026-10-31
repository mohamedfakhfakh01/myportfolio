import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Gère la **langue** de l'application (français/anglais) et mémorise le choix.
///
/// Même principe que le contrôleur de thème : un [ChangeNotifier] qui prévient
/// le [MaterialApp] pour qu'il se reconstruise dans la bonne langue, et qui
/// enregistre le choix dans un petit fichier (via `path_provider`).
class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  /// Langue actuelle (français par défaut).
  Locale get locale => _locale;

  /// Vrai si le français est actif.
  bool get isFrench => _locale.languageCode == 'fr';

  LocaleController() {
    _load();
  }

  /// Change la langue, puis enregistre le choix.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    await _save();
  }

  /// Bascule entre français et anglais.
  Future<void> toggle() =>
      setLocale(isFrench ? const Locale('en') : const Locale('fr'));

  Future<File> _prefFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/locale_preference.txt');
  }

  Future<void> _load() async {
    try {
      final File file = await _prefFile();
      if (!await file.exists()) return;
      final String value = (await file.readAsString()).trim();
      if (value == 'en' || value == 'fr') {
        _locale = Locale(value);
        notifyListeners();
      }
    } catch (_) {
      // Échec de lecture (ex : tests) : on garde la langue par défaut.
    }
  }

  Future<void> _save() async {
    try {
      final File file = await _prefFile();
      await file.writeAsString(_locale.languageCode);
    } catch (_) {
      // Échec d'écriture non bloquant.
    }
  }
}
