import 'package:digi_xpense/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({Key? key}) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  Map<String, dynamic>? selectedLanguage;

  final List<Map<String, dynamic>> languages = [
    {
      'locale': const Locale('en'),
      'name': 'English',
      'flag':
          'https://upload.wikimedia.org/wikipedia/en/a/ae/Flag_of_the_United_Kingdom.svg',
    },
    {
      'locale': const Locale('fr'),
      'name': 'français',
      'flag':
          'https://upload.wikimedia.org/wikipedia/en/c/c3/Flag_of_France.svg',
    },
    {
      'locale': const Locale('ar'),
      'name': 'عربي',
      'flag':
          'http://upload.wikimedia.org/wikipedia/commons/0/0d/Flag_of_Saudi_Arabia.svg',
    },
    {
      'locale': const Locale('zh'),
      'name': '中文',
      'flag':
          'https://upload.wikimedia.org/wikipedia/commons/f/fa/Flag_of_the_People%27s_Republic_of_China.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedLanguage = languages[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          dropdownColor: Colors.white,
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(100), // Make it circular
            child: SizedBox(
              width: 24,
              height: 24,
              child: selectedLanguage?['flag'] != null
                  ? SvgPicture.network(
                      selectedLanguage!['flag'],
                      fit: BoxFit.cover,
                      width: 24,
                      height: 24,
                      placeholderBuilder: (context) => SvgPicture.network(
                        'https://upload.wikimedia.org/wikipedia/en/a/ae/Flag_of_the_United_Kingdom.svg',
                        fit: BoxFit.cover,
                        width: 24,
                        height: 24,
                      ),
                    )
                  : SvgPicture.network(
                      'https://upload.wikimedia.org/wikipedia/en/a/ae/Flag_of_the_United_Kingdom.svg',
                      fit: BoxFit.cover,
                      width: 24,
                      height: 24,
                    ),
            ),
          ),

          value: selectedLanguage,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedLanguage = value;
              });
              // Get.updateLocale(value['locale']);
              Provider.of<LocaleNotifier>(context, listen: false)
                  .setLocale(value['locale']);
            }
          },
          items: languages.map((lang) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: lang,
              child: Row(
                children: [
                  SvgPicture.network(
                    lang['flag'],
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 6),
                  Text(lang['name']),
                ],
              ),
            );
          }).toList(),
          // Display selected item
          selectedItemBuilder: (context) {
            return languages.map((lang) {
              return const Row(
                children: [
                  // Image.asset(
                  //   lang['flag'],
                  //   width: 20,
                  //   height: 20,
                  //   fit: BoxFit.cover,
                  // ),
                  // const SizedBox(width: 6),
                  // Text(
                  //   lang['name'],
                  //   style: const TextStyle(color: Colors.white),
                  // ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
