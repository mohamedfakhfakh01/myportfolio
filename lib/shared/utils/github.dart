/// Ramène une saisie GitHub au **pseudo** seul, ou `null` si elle est vide.
///
/// L'utilisateur colle souvent son adresse complète. Or le pseudo sert à
/// construire l'adresse de l'API (`/users/<pseudo>/repos`) et le lien du PDF :
/// une URL entière les casserait.
/// - `' alice '`, `'@alice'` → `'alice'`
/// - `'https://www.github.com/alice?tab=repositories'` → `'alice'`
/// - `'github.com/alice/'` → `'alice'`
String? githubUsernameFrom(String input) {
  String v = input.trim();
  final int at = v.toLowerCase().indexOf('github.com/');
  if (at != -1) v = v.substring(at + 'github.com/'.length);
  // Retire « ?… » / « #… », puis ne garde que le premier segment du chemin.
  v = v.split(RegExp(r'[?#]')).first;
  v = v.split('/').firstWhere((s) => s.isNotEmpty, orElse: () => '');
  v = v.replaceFirst(RegExp(r'^@+'), '').trim();
  return v.isEmpty ? null : v;
}

/// Vrai si [username] a la **forme** d'un pseudo GitHub : lettres, chiffres et
/// tirets, 39 caractères au plus, sans tiret au début.
///
/// Règle volontairement un peu souple (GitHub interdit aussi « -- » et le tiret
/// final, mais de très vieux comptes en ont) : c'est GitHub qui tranche ensuite
/// si le compte existe. Ce contrôle évite surtout d'envoyer une adresse cassée
/// (espaces, accents…) à l'API.
bool isValidGithubUsername(String username) =>
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9-]{0,38}$').hasMatch(username);
