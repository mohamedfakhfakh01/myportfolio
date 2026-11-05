import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/student.dart';

/// Section « Contact » du profil : e-mail, téléphone, LinkedIn et localisation.
///
/// N'affiche que les coordonnées renseignées, et rend l'e-mail / le téléphone /
/// LinkedIn **cliquables** (mailto:, tel:, URL). Si rien n'est renseigné, la
/// section ne s'affiche pas.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.student});

  final Student student;

  Future<void> _open(BuildContext context, String url) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Uri? uri = Uri.tryParse(url);
    final bool ok = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.linkError)));
    }
  }

  /// Normalise un LinkedIn (URL complète, ou pseudo → profil « in/… »).
  String _linkedinUrl(String value) {
    final String v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.contains('linkedin.com')) return 'https://$v';
    return 'https://www.linkedin.com/in/${v.replaceAll('@', '')}';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    final List<Widget> rows = [];

    void addRow(IconData icon, String label, {String? url}) {
      rows.add(
        InkWell(
          onTap: url == null ? null : () => _open(context, url),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: text.bodyMedium?.copyWith(
                      color: url == null
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight:
                          url == null ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String? email = student.email;
    final String? phone = student.phone;
    final String? linkedin = student.linkedin;
    final String? location = student.location;

    if (email != null && email.isNotEmpty) {
      addRow(Icons.email_outlined, email, url: 'mailto:$email');
    }
    if (phone != null && phone.isNotEmpty) {
      addRow(Icons.phone_outlined, phone,
          url: 'tel:${phone.replaceAll(' ', '')}');
    }
    if (linkedin != null && linkedin.isNotEmpty) {
      addRow(Icons.link, linkedin, url: _linkedinUrl(linkedin));
    }
    if (location != null && location.isNotEmpty) {
      addRow(Icons.place_outlined, location);
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.contactTitle, style: text.titleMedium),
        const SizedBox(height: 4),
        ...rows,
        const SizedBox(height: 24),
      ],
    );
  }
}
