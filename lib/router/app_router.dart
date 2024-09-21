import 'package:assivoice/pages/home_page.dart';
import 'package:assivoice/pages/setting_page.dart';
import 'package:assivoice/pages/welcome_page.dart';
import 'package:assivoice/router/app_router_name.dart';
import 'package:assivoice/services/preference_service.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteName.welcomePage,
        builder: (context, state) => const WelcomePage(),
        redirect: (context, state) {
          if (PreferenceService.isUserNameActiveSync()) {
            return '/home';
          }
          return '/';
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRouteName.homePage,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/setting',
        name: AppRouteName.settingPage,
        builder: (context, state) => const SettingPage(),
      ),
    ],
  );
}
