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
