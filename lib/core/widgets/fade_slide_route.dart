import 'package:flutter/material.dart';

/// Crée une **transition de page personnalisée** : la nouvelle page apparaît
/// en **fondu** avec un **léger glissement vers le haut**.
///
/// Remplace la transition par défaut (`MaterialPageRoute`) pour un rendu plus
/// doux et moderne. Les animations `Hero` continuent de fonctionner par-dessus.
Route<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
