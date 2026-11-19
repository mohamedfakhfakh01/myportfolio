/// Vrai si [value] a la forme d'une adresse e-mail : `nom@domaine.ext`, sans
/// espace. Vérification de **forme** seulement (on ne peut pas savoir hors
/// ligne si la boîte existe) : elle attrape les fautes de frappe courantes
/// (« alice@ », « alice.example.com ») avant qu'elles finissent dans le CV.
bool isValidEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s.]+$').hasMatch(value.trim());
