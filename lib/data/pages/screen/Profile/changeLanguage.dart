import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digi_xpense/main.dart'; // where LocaleNotifier is defined
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digi_xpense/main.dart'; // where LocaleNotifier is defined

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // map of language codes to their display names
  static const _languages = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'zh': '中文',
  };

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final currentCode = localeNotifier.locale.languageCode;
    final loc = AppLocalizations.of(context)!;

    return Directionality(
      textDirection:
          (currentCode == 'ar' ? TextDirection.rtl : TextDirection.ltr),
      child: Scaffold(
        appBar: AppBar(title:  Text(loc.setting ?? 'Settings')),
        body: ListView(
          children: _languages.entries.map((entry) {
            final code = entry.key;
            final name = entry.value;
            return RadioListTile<String>(
              title: Text(name),
              value: code,
              groupValue: currentCode,
              onChanged: (selected) {
                if (selected != null) {
                  localeNotifier.setLocale(Locale(selected));
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}