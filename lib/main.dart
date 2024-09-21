import 'package:assivoice/config/api_key_config.dart';
import 'package:assivoice/providers/app_providers.dart';
import 'package:assivoice/router/app_router.dart';
import 'package:assivoice/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assivoice/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceService.init(); // Initialize SharedPreferences
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: ApiKeyConfig.googleGeminiApiKey);
  runApp(
    const ProviderScope(
      child: AssiVoice(),
    ),
  );
}

class AssiVoice extends ConsumerWidget {
  const AssiVoice({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the seed color from the provider
    final seedColor = ref.watch(seedColorProvider);
    // Watch the theme mode from the provider
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(seedColor),
      darkTheme: AppTheme.darkTheme(seedColor),
      themeMode: themeMode,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
    );
  }
}
