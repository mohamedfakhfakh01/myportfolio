import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/shared/utils/linkedin.dart';

void main() {
  group('linkedinUrl', () {
    test('une URL complète est gardée telle quelle', () {
      expect(linkedinUrl('https://www.linkedin.com/in/alice'),
          'https://www.linkedin.com/in/alice');
    });

    test('« linkedin.com/… » reçoit https://', () {
      expect(linkedinUrl(' linkedin.com/in/alice '),
          'https://linkedin.com/in/alice');
    });

    test('un pseudo (même avec @) devient un profil in/…', () {
      expect(linkedinUrl('@alice-martin'),
          'https://www.linkedin.com/in/alice-martin');
    });
  });
}
