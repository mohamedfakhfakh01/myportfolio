import 'package:flutter/material.dart';

// Briques d'animation partagées. Règle commune : une animation doit AIDER à
// comprendre (ordre d'apparition, valeur qui se construit, retour au toucher),
// et l'état final affiché est toujours la valeur exacte.
//
// Toutes respectent le réglage iOS « Réduire les animations »
// (Réglages ▸ Accessibilité ▸ Mouvement) : tout s'affiche alors immédiatement.

/// Vrai si l'utilisateur a demandé à réduire les animations.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// [duration], ou zéro si l'utilisateur a demandé à réduire les animations.
Duration motionDuration(BuildContext context, Duration duration) =>
    reduceMotion(context) ? Duration.zero : duration;

/// Fait apparaître [child] en fondu avec un léger glissement vers le haut,
/// **après les éléments précédents** : l'élément n°[index] démarre
/// [step] × index plus tard (cascade), plafonné à [maxDelayedItems] pour qu'une
/// longue liste n'attende pas.
///
/// Un seul contrôleur et un intervalle décalé, sans minuteur : rien ne reste en
/// attente si l'écran est quitté avant la fin.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
    this.maxDelayedItems = 6,
  });

  final Widget child;
  final int index;
  final Duration step;
  final Duration duration;
  final int maxDelayedItems;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final Duration delay =
        widget.step * widget.index.clamp(0, widget.maxDelayedItems);
    final Duration total = delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      // Rien pendant le délai, puis la courbe douce sur la durée normale.
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      if (reduceMotion(context)) {
        _controller.value = 1; // affichage immédiat
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _progress,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(_progress),
          child: widget.child,
        ),
      );
}

/// Nombre entier qui **compte** de 0 jusqu'à [value] (puis d'une valeur à la
/// nouvelle quand elle change). Le dernier chiffre affiché est toujours
/// exactement [value].
class CountUpText extends StatelessWidget {
  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final TextStyle? style;

  /// Texte collé après le nombre (ex. « % »).
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: value),
        duration: motionDuration(context, duration),
        curve: Curves.easeOutCubic,
        builder: (context, shown, _) => Text('$shown$suffix', style: style),
      );
}

/// Retour au toucher : [child] rétrécit légèrement tant que le doigt appuie,
/// puis reprend sa taille. N'intercepte pas le toucher (l'ondulation et le
/// `onTap` de l'enfant continuent de fonctionner).
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: motionDuration(context, const Duration(milliseconds: 120)),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}
