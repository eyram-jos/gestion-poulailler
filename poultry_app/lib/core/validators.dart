String? validateEmail(String? v) {
  if (v == null || v.isEmpty) return 'Champ obligatoire';
  if (!v.contains('@')) return 'Email invalide';
  return null;
}
String? validateNotEmpty(String? v) =>
    (v == null || v.isEmpty) ? 'Champ obligatoire' : null;
