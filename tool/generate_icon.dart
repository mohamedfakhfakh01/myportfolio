// Génère l'icône de l'app et le logo du splash, sans outil externe.
//
// Lancer : `dart run tool/generate_icon.dart`
// Produit : assets/icon/icon.png (1024, dégradé bleu + carte de profil)
//           assets/icon/splash_logo.png (512, carte blanche sur fond transparent)
//
// Motif choisi : une « carte de profil » (avatar + lignes de texte) = portfolio.
import 'dart:io';

import 'package:image/image.dart' as img;

// Couleurs de l'app (voir lib/app/theme/app_colors.dart).
final _blue = img.ColorRgb8(0x3B, 0x82, 0xF6);
final _blueDark = img.ColorRgb8(0x25, 0x63, 0xEB);
final _white = img.ColorRgb8(255, 255, 255);
final _gray = img.ColorRgb8(0xCB, 0xD5, 0xE1);

/// Dessine la « carte de profil » (avatar + 3 lignes) centrée sur [img.Image].
/// [s] est le côté de l'image ; les positions sont proportionnelles.
void _drawCard(img.Image image, int s) {
  double p(double f) => f * s; // raccourci : fraction → pixels
  img.fillRect(image,
      x1: p(0.265).round(),
      y1: p(0.225).round(),
      x2: p(0.735).round(),
      y2: p(0.785).round(),
      radius: p(0.06).round(),
      color: _white);
  img.fillCircle(image,
      x: (s / 2).round(),
      y: p(0.39).round(),
      radius: p(0.093).round(),
      color: _blue);
  img.fillRect(image,
      x1: p(0.345).round(),
      y1: p(0.535).round(),
      x2: p(0.655).round(),
      y2: p(0.575).round(),
      radius: p(0.02).round(),
      color: _gray);
  img.fillRect(image,
      x1: p(0.385).round(),
      y1: p(0.61).round(),
      x2: p(0.615).round(),
      y2: p(0.646).round(),
      radius: p(0.018).round(),
      color: _gray);
  img.fillRect(image,
      x1: p(0.385).round(),
      y1: p(0.675).round(),
      x2: p(0.615).round(),
      y2: p(0.711).round(),
      radius: p(0.018).round(),
      color: _gray);
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // --- Icône : dégradé bleu plein + carte de profil ---
  const size = 1024;
  final icon = img.Image(width: size, height: size);
  for (int y = 0; y < size; y++) {
    final t = y / size;
    int mix(num a, num b) => (a + (b - a) * t).round();
    final c = img.ColorRgb8(
      mix(_blue.r, _blueDark.r),
      mix(_blue.g, _blueDark.g),
      mix(_blue.b, _blueDark.b),
    );
    img.drawLine(icon, x1: 0, y1: y, x2: size - 1, y2: y, color: c);
  }
  _drawCard(icon, size);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(icon));

  // --- Logo du splash : carte blanche sur fond transparent ---
  const ssize = 512;
  final splash = img.Image(width: ssize, height: ssize, numChannels: 4);
  _drawCard(splash, ssize);
  File('assets/icon/splash_logo.png').writeAsBytesSync(img.encodePng(splash));

  stdout.writeln('OK : assets/icon/icon.png + assets/icon/splash_logo.png');
}
