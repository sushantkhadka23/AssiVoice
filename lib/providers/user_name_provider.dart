import 'package:assivoice/services/preference_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier() : super('') {
    // load the user name when the notifier is initialized
    _loadUserName();
  }

  //to load the stored username from preferences
  Future<void> _loadUserName() async {
    final userName = await PreferenceService.getUserName();
    state = userName;
  }

  //to update and save the username
  Future<void> updateUserName(String name) async {
    state = name;
    await PreferenceService.setUserName(name);
  }
}
