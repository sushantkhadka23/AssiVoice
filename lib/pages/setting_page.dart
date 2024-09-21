import 'dart:io';
import 'package:assivoice/providers/app_providers.dart';
import 'package:assivoice/router/app_router_name.dart';
import 'package:assivoice/services/preference_service.dart';
import 'package:assivoice/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController userNameController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
          ),
          onPressed: () => context.goNamed(AppRouteName.homePage),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Appearance',
              icon: Icons.palette,
              child: _buildThemeModeCard(themeMode, ref),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'User Settings',
              icon: Icons.person,
              child: _buildUserSettingsCard(
                context,
                userNameController,
                colorScheme,
                ref,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Color Settings',
              icon: Icons.color_lens,
              child: _buildColorSettingsCard(ref, context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        child,
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeCard(ThemeMode themeMode, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRadioThemeModeList(
            title: 'Light Mode',
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (mode) => toggleTheme(mode!, ref),
          ),
          _buildRadioThemeModeList(
            title: 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (mode) => toggleTheme(mode!, ref),
          ),
          _buildRadioThemeModeList(
            title: 'System Mode',
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (mode) => toggleTheme(mode!, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSettingsCard(
    BuildContext context,
    TextEditingController userNameController,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            _buildElevatedButton(
              'Change User Name',
              () => _changeUserName(
                context,
                userNameController,
                ref,
              ),
              colorScheme,
              Icons.person,
              'Change User Name',
              colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _buildElevatedButton(
              'Clear User Name',
              () => _clearUserName(
                context,
                userNameController,
                ref,
              ),
              colorScheme,
              Icons.delete,
              'Clear User Name',
              colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSettingsCard(
    WidgetRef ref,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: AppTheme.availableColors.map((color) {
            return GestureDetector(
              onTap: () => _updateSeedColor(ref, color, context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32.2,
                height: 32.2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onSurface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRadioThemeModeList({
    required String title,
    required ThemeMode value,
    required ThemeMode? groupValue,
    required void Function(ThemeMode?)? onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildElevatedButton(
    String text,
    VoidCallback onPressed,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    Color color,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

void toggleTheme(ThemeMode mode, WidgetRef ref) async {
  ref.read(themeModeProvider.notifier).updateThemeMode(mode);
}

Future<void> _changeUserName(
  BuildContext context,
  TextEditingController userNameController,
  WidgetRef ref,
) async {
  if (userNameController.text.isNotEmpty) {
    final newUserName = userNameController.text;
    await PreferenceService.setUserName(newUserName);
    ref.read(userNameProvider.notifier).updateUserName(newUserName);
    userNameController.clear();
    if (context.mounted) {
      context.goNamed(AppRouteName.homePage);
    }
  }
}

Future<void> _clearUserName(
  BuildContext context,
  TextEditingController userNameController,
  WidgetRef ref,
) async {
  await PreferenceService.clearUserName();
  userNameController.clear();

  if (context.mounted) {
    context.goNamed(AppRouteName.welcomePage);
  }
}

Future<void> _updateSeedColor(
  WidgetRef ref,
  Color color,
  BuildContext context,
) async {
  ref.read(seedColorProvider.notifier).updateSeedColor(color);
}
