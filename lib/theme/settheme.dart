import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPickerGrid extends StatefulWidget {
  const ColorPickerGrid({Key? key}) : super(key: key);

  @override
  State<ColorPickerGrid> createState() => _ColorPickerGridState();
}

class _ColorPickerGridState extends State<ColorPickerGrid> {
  String? _selectedThemeKey; // temporary selection
  final controller = Get.put(Controller());
  final Map<Color, String> lightThemeColors = {
    Colors.red: "RED_THEME",
    Colors.green: "GREEN_THEME",
    Colors.blue: "BLUE_THEME",
    Colors.orange: "ORANGE_THEME",
    Colors.purple: "PURPLE_THEME",
    Colors.indigo: "INDIGO_THEME",
  };

  final Map<Color, String> darkThemeColors = {
    const Color(0xFF6A1B9A): "DARK_PURPLE_THEME",
    const Color(0xFF0D47A1): "DARK_BLUE_THEME",
    const Color(0xFF1A237E): "DARK_INDIGO_THEME",
    const Color(0xFF1B5E20): "DARK_GREEN_THEME",
    const Color(0xFFB71C1C): "DARK_RED_THEME",
    const Color(0xFFE65100): "DARK_ORANGE_THEME",
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  Future<void> _loadSavedSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedThemeKey = prefs.getString("ThemeColor");
      controller.themeColorCode = prefs.getString("ThemeColor");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Light Theme Colors"),
              _buildColorGrid(lightThemeColors),
              const SizedBox(height: 24),
              _buildSectionTitle("Dark Theme Colors"),
              _buildColorGrid(darkThemeColors),
              const SizedBox(height: 24),
              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: () {
              //       if (_selectedThemeKey != null) {
              //         final color = ThemeNotifier.themeColorMap[_selectedThemeKey!]!;
              //         themeNotifier.setColor(color, themeKey: _selectedThemeKey!);
              //       }
              //     },
              //     icon: const Icon(Icons.save),
              //     label: const Text("Apply Theme"),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildColorGrid(Map<Color, String> colors) {
    final controller = Get.put(Controller());
    return SizedBox(
      height: 160,
      child: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.0,
        children: colors.entries.map((entry) {
          final bool isSelected = _selectedThemeKey == entry.value;

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedThemeKey = entry.value;
                controller.themeColorCode = entry.value;
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("ThemeColor", entry.value); // save only
              print("🎨 Selected (not applied): ${entry.value}");
            },
            child: Card(
              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.black87 : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: entry.key,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      entry.value
                          .replaceAll("_THEME", "")
                          .replaceAll("DARK_", "")
                          .replaceAll("LIGHT_", ""),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
