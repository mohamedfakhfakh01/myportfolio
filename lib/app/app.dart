import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/portfolio/presentation/pages/home_page.dart';
import '../features/portfolio/providers/portfolio_provider.dart';
import 'theme/app_theme.dart';

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
    return ChangeNotifierProvider(
      create: (_) => PortfolioProvider(),
      child: MaterialApp(
        title: 'MyPortfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        // Écran de départ : la liste des deux portfolios.
        home: const HomePage(),
      ),
    );
  }
}
