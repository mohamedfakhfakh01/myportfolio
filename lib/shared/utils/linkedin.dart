/// Normalise une valeur LinkedIn saisie par l'utilisateur en **URL complète** :
/// une URL est gardée telle quelle, « linkedin.com/… » reçoit `https://`, et
/// un simple pseudo devient le profil `https://www.linkedin.com/in/<pseudo>`.
///
/// Source unique de la règle : utilisée par l'écran (lien cliquable) et par
/// l'export PDF (adresse imprimée).
String linkedinUrl(String value) {
  final String v = value.trim();
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  if (v.contains('linkedin.com')) return 'https://$v';
  return 'https://www.linkedin.com/in/${v.replaceAll('@', '')}';
}
