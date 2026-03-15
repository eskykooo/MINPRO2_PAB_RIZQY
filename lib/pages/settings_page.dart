import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: const [
                    Text(
                      "Pengaturan",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    Icon(Icons.settings_rounded, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildThemeTile(context, "System", ThemeMode.system, isFirst: true),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildThemeTile(context, "Light", ThemeMode.light),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                      _buildThemeTile(context, "Dark", ThemeMode.dark, isLast: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, String title, ThemeMode mode, {bool isFirst = false, bool isLast = false}) {
    final isSelected = currentThemeMode == mode;
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      onTap: () => onThemeModeChanged(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF7C3AED) : null,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}