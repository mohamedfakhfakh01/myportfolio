// L'icône et l'écran de démarrage sont générés HORS de l'app (script Dart,
// pubspec, outils de génération) : ils ne peuvent pas lire app_colors.dart.
// Ce test vérifie qu'ils gardent les couleurs de l'app (une seule source de
// vérité) : si on change l'indigo dans app_colors.dart sans régénérer, il
// échoue. (Cas réel : l'écran de démarrage est resté en ancien bleu #3B82F6
// après le passage de l'app à l'indigo.)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:myportfolio/app/theme/app_colors.dart';

import '../tool/generate_icon.dart' as generator;

/// `#RRGGBB` (majuscules) d'une couleur ARGB.
String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Couleur RGB (sans alpha) du pixel ([x], [y]) d'une image PNG.
int _pixel(String path, int x, int y) {
  final img.Image image = img.decodePng(File(path).readAsBytesSync())!;
  final img.Pixel p = image.getPixel(x, y);
  return (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
}

final String _primary = _hex(AppColors.primary.toARGB32());
final String _violet = _hex(AppColors.violet.toARGB32());

void main() {
  test('le script de l\'icône utilise l\'indigo et le violet de l\'app', () {
    expect(_hex(generator.iconGradientStart), _primary);
    expect(_hex(generator.iconGradientEnd), _violet);
  });

  test('icône générée : indigo en haut à gauche, violet en bas à droite', () {
    const String icon = 'assets/icon/icon.png';
    expect(_hex(_pixel(icon, 0, 0)), _primary);
    expect(_hex(_pixel(icon, 1023, 1023)), _violet);
  });

  test('écran de démarrage : fond indigo partout (pubspec, Android, iOS)', () {
    // pubspec.yaml : configuration de flutter_native_splash (2 entrées).
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final String splash =
        pubspec.substring(pubspec.indexOf('flutter_native_splash:\n'));
    final colors = RegExp(r'color: "(#[0-9A-Fa-f]{6})"')
        .allMatches(splash)
        .map((m) => m.group(1)!.toUpperCase());
    expect(colors, [_primary, _primary]);

    // Android 12+ : couleur écrite dans les styles (jour et nuit).
    for (final String styles in [
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ]) {
      expect(File(styles).readAsStringSync(),
          contains('windowSplashScreenBackground">$_primary<'),
          reason: styles);
    }

    // iOS : image de fond unie.
    expect(
      _hex(_pixel(
          'ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png',
          0,
          0)),
      _primary,
    );
  });

  test('plus aucune trace de l\'ancien bleu #3B82F6', () {
    for (final String path in [
      'pubspec.yaml',
      'tool/generate_icon.dart',
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ]) {
      expect(File(path).readAsStringSync().toUpperCase(),
          isNot(contains('3B82F6')),
          reason: path);
    }
  });
}
