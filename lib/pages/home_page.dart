import 'package:assivoice/providers/app_providers.dart';
import 'package:assivoice/router/app_router_name.dart';
import 'package:assivoice/services/generative_model_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speechToText;
  String _spokenText = 'Press the button and start speaking...';
  String _generatedResponse = '';
  bool _isListening = false;
  bool _isProcessing = false;
  // ignore: unused_field
  bool _isToggled = false;

  Timer? _speechTimer;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  final _generativeModelService = GenerativeModelService();
  final Uri _youtubeUrl = Uri.parse('https://www.youtube.com');
  final Uri _spotifyUrl = Uri.parse('https://www.spotify.com');

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechRecognition();
    _initializeTextToSpeech();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _speechTimer?.cancel();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  /// Initializes speech recognition.
  Future<void> _initializeSpeechRecognition() async {
    bool available = await _speechToText.initialize();
    if (!mounted) return;
    setState(() {
      if (!available) {
        _spokenText = 'Speech recognition is not available on this device';
      }
    });
  }

  /// Initializes text-to-speech settings.
  Future<void> _initializeTextToSpeech() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
  }

  /// Starts listening for speech input and processes the speech result.
  Future<void> _startListening() async {
    await _delayFunction();
    if (!_isListening && await _speechToText.initialize()) {
      setState(() {
        _isListening = true;
        _spokenText = 'Listening...';
        _generatedResponse = '';
        _isToggled = true; // Enlarge the button when listening starts
      });
      await _speechToText.listen(onResult: _onSpeechResult);
      _startSpeechTimer(); // Start tracking idle time
    }
  }

  /// Stops listening for speech input.
  Future<void> _stopListening() async {
    await _delayFunction();
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _spokenText = '';
      _isToggled = false; // Shrink the button when listening stops
    });
    _stopSpeechTimer();
  }

  /// Processes the recognized speech.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _spokenText = result.recognizedWords;
    });
    if (result.finalResult) {
      _processSpeechInput();
      _stopSpeechTimer();
    } else {
      _startSpeechTimer(); // Restart the timer if speech continues
    }
  }

  /// Processes the spoken input through the generative AI and provides a spoken response.
  Future<void> _processSpeechInput() async {
    setState(() => _isProcessing = true);
    try {
      if (_spokenText.toLowerCase().contains('open youtube')) {
        await _openYouTube();
        setState(() => _isProcessing = false);
        return;
      } else if (_spokenText.toLowerCase().contains('open spotify')) {
        await _openSpotify();
        setState(() => _isProcessing = false);
        return;
      }
      final response =
          await _generativeModelService.getResponseUsingModel(_spokenText);
      setState(() {
        _generatedResponse = response;
        _isProcessing = false;
      });
      await _flutterTts.speak(response);
    } catch (error) {
      setState(() {
        _generatedResponse = 'An error occurred while generating the response.';
        _isProcessing = false;
      });
    }
  }

  /// Starts a timer that resets the state if the user doesn't speak for 3 seconds.
  void _startSpeechTimer() {
    _speechTimer?.cancel(); // Cancel the previous timer if it exists
    _speechTimer = Timer(const Duration(seconds: 3), () {
      if (_isListening) {
        _stopListening(); // Stop listening after 3 seconds of inactivity
      }
    });
  }

  /// Stops the timer.
  void _stopSpeechTimer() {
    _speechTimer?.cancel();
  }

  Future<void> _delayFunction() async {
    setState(() => _isToggled = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isToggled = false);
  }

  Future<void> _processTextInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _spokenText = text;
      _isProcessing = true;
    });

    try {
      if (text.toLowerCase().contains('open youtube')) {
        await _openYouTube();
        setState(() => _isProcessing = false);
        return;
      } else if (text.toLowerCase().contains('open spotify')) {
        await _openSpotify();
        setState(() => _isProcessing = false);
        return;
      }
      final response =
          await _generativeModelService.getResponseUsingModel(text);
      setState(() {
        _generatedResponse = response;
        _isProcessing = false;
      });
      await _flutterTts.speak(response);
    } catch (error) {
      setState(() {
        _generatedResponse = 'An error occurred while generating the response.';
        _isProcessing = false;
      });
    }

    _textController.clear();
    _textFocusNode.unfocus();
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  /// Opens YouTube in the default browser.
  Future<void> _openYouTube() async {
    if (!await launchUrl(_youtubeUrl)) {
      throw Exception('Could not launch $_youtubeUrl');
    }
  }

  /// Opens Spotify in the default browser.
  Future<void> _openSpotify() async {
    if (!await launchUrl(_spotifyUrl)) {
      throw Exception('Could not launch $_spotifyUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: _buildBody(colorScheme),
      backgroundColor: colorScheme.surface,
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Consumer(builder: (context, ref, child) {
        final userName = ref.watch(userNameProvider);
        return Text(
          'Hi $userName, let\'s chat!',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        );
      }),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: colorScheme.onSurface),
          onPressed: () {
            context.goNamed(AppRouteName.settingPage);
          },
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _buildConversationArea(colorScheme),
          ),
          _buildTextInputArea(colorScheme),
        ],
      ),
    );
  }

  Widget _buildConversationArea(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: colorScheme.outline),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConversationBubble(
                  _spokenText.isNotEmpty && _isListening
                      ? _spokenText
                      : 'Tap the mic to start speaking or type for messaging',
                  isUser: true,
                  colorScheme: colorScheme,
                ),
                if (_generatedResponse.isNotEmpty)
                  _buildConversationBubble(
                    _generatedResponse,
                    isUser: false,
                    colorScheme: colorScheme,
                  ),
              ],
            ),
          ),
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationBubble(
    String text, {
    required bool isUser,
    required ColorScheme colorScheme,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft:
                isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? colorScheme.onSecondaryContainer
                : colorScheme.onPrimaryContainer,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      key: ValueKey<bool>(_isListening),
                      color: _isListening
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                  ),
                  onPressed: _toggleListening,
                ),
              ),
              onSubmitted: (_) => _processTextInput(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _processTextInput,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
