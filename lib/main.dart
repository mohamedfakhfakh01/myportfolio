import 'package:flutter/material.dart';

import 'app/app.dart';

/// Point d'entrée de l'application.
///
/// `main()` est la toute première fonction exécutée au lancement.
/// `runApp(...)` attache notre widget racine [MyPortfolioApp] à l'écran.
///
/// On garde ce fichier VOLONTAIREMENT minimal : toute la configuration
/// (thème, routes) vit dans `app/app.dart`, pas ici. (Bonne pratique :
/// ne pas entasser la logique dans main.dart.)
void main() {
  runApp(const MyPortfolioApp());
}
