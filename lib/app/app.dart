import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/portfolio/providers/portfolio_provider.dart';
import '../l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'main_shell.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Widget racine de l'application MyPortfolio.
///
/// C'est le premier widget « visuel » de l'app. Il crée le [MaterialApp], qui
/// fournit à toute l'application :
/// - le thème (couleurs, police, styles) défini dans [AppTheme] ;
/// - la navigation (routes) ;
/// - les textes de base (titre de l'app).
///
/// C'est un [StatelessWidget] : il n'a pas d'état interne qui change, il se
/// contente de décrire une configuration fixe.
class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // `ChangeNotifierProvider` rend le [PortfolioProvider] accessible à tous
    // les écrans de l'application (ici, l'écran d'accueil). Il est créé une
    // seule fois, au-dessus du MaterialApp.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LocaleController()),
      ],
      // On reconstruit le MaterialApp quand le thème OU la langue change.
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, themeController, localeController, _) {
          // La palette globale doit correspondre au thème avant de le construire.
          AppColors.applyBrightness(themeController.brightness);
          return MaterialApp(
            title: 'MyPortfolio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeFor(themeController.brightness),
            // Langue de l'app + traductions (français/anglais).
            locale: localeController.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Écran de départ : la coquille à onglets (Accueil / À propos / Réglages).
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
