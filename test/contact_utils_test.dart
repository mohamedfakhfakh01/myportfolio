import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/shared/utils/email.dart';
import 'package:myportfolio/shared/utils/github.dart';

void main() {
  group('githubUsernameFrom', () {
    test('pseudo simple, espaces et @ retirés', () {
      expect(githubUsernameFrom(' alice '), 'alice');
      expect(githubUsernameFrom('@alice'), 'alice');
      expect(githubUsernameFrom('mohamedfakhfakh01'), 'mohamedfakhfakh01');
    });

    test('adresse complète ramenée au pseudo', () {
      expect(githubUsernameFrom('https://github.com/alice'), 'alice');
      expect(githubUsernameFrom('github.com/alice/'), 'alice');
      expect(githubUsernameFrom('https://www.GitHub.com/alice/myrepo'), 'alice');
      expect(
        githubUsernameFrom('https://github.com/alice?tab=repositories'),
        'alice',
      );
    });

    test('vide ou sans pseudo → null', () {
      expect(githubUsernameFrom(''), isNull);
      expect(githubUsernameFrom('   '), isNull);
      expect(githubUsernameFrom('https://github.com/'), isNull);
      expect(githubUsernameFrom('@'), isNull);
    });
  });

  group('isValidEmail', () {
    test('adresses valides', () {
      for (final e in ['alice@example.com', ' a.b+c@sub.domaine.tn ']) {
        expect(isValidEmail(e), isTrue, reason: e);
      }
    });

    test('fautes de frappe courantes refusées', () {
      for (final e in [
        'alice@', 'alice.example.com', 'alice@exemple', 'a b@c.com',
        '@example.com', 'alice@@example.com', 'alice@example.',
      ]) {
        expect(isValidEmail(e), isFalse, reason: e);
      }
    });
  });
}
