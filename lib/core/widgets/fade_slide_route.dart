import 'package:flutter/material.dart';
import 'motion.dart';

/// Crée une **transition de page personnalisée** : la nouvelle page apparaît
/// en **fondu** avec un **léger glissement vers le haut**.
///
/// Remplace la transition par défaut (`MaterialPageRoute`) pour un rendu plus
/// doux et moderne. Les animations `Hero` continuent de fonctionner par-dessus.
///
/// [settings] porte le **nom** de la route et ses arguments (routes nommées,
/// voir `lib/app/app_routes.dart`).
Route<T> fadeSlideRoute<T>(Widget page, {RouteSettings? settings}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // « Réduire les animations » : la page apparaît sans mouvement.
      if (reduceMotion(context)) return child;
      // Courbe douce qui ralentit à la fin.
      final Animation<double> curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06), // part légèrement plus bas
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
