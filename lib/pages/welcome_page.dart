import 'package:assivoice/providers/app_providers.dart';
import 'package:assivoice/services/preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isAudioPermissionGranted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _checkAudioPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _isAudioPermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestAudioPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _isAudioPermissionGranted = status.isGranted;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkAudioPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void _onFormSubmitted(WidgetRef ref) async {
    if (_formKey.currentState?.validate() ?? false) {
      final userName = _nameController.text;
      await PreferenceService.setUserName(userName);
      ref.read(userNameProvider.notifier).updateUserName(userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer(
            builder: (context, ref, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.record_voice_over,
                    size: screenSize.height * 0.12,
                    color: theme.onSurface,
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Text(
                    'Welcome to Voice Assistant',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.035,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.06),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            filled: true,
                            fillColor: theme.onSurface.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: theme.onSurface,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) => _onFormSubmitted(ref),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        ElevatedButton.icon(
                          onPressed: _isAudioPermissionGranted
                              ? () {
                                  _onFormSubmitted(ref);
                                  context.go('/home');
                                }
                              : _requestAudioPermission,
                          icon: Icon(
                            Icons.mic,
                            color: theme.onPrimary,
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                              double.infinity,
                              screenSize.height * 0.056,
                            ),
                            backgroundColor: theme.primary,
                            foregroundColor: theme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          label: Text(
                            _isAudioPermissionGranted
                                ? 'Get Started'
                                : 'Grant Audio Permission',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isAudioPermissionGranted
                              ? 'Audio permission granted'
                              : 'Audio permission required for voice assistant',
                          style: TextStyle(
                            color: theme.onSurface,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
