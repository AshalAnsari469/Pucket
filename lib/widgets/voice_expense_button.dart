import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../screens/add_expense_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoiceExpenseButton extends StatefulWidget {
  const VoiceExpenseButton({super.key});

  @override
  State<VoiceExpenseButton> createState() => _VoiceExpenseButtonState();
}

class _VoiceExpenseButtonState extends State<VoiceExpenseButton> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _startListening() async {
    _lastWords = '';
    await _speechToText.listen(onResult: (result) {
      if (mounted) {
        setState(() {
          _lastWords = result.recognizedWords;
        });
      }
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    
    if (_lastWords.isNotEmpty) {
      final wordsToPush = _lastWords;
      setState(() => _lastWords = '');
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AddExpenseScreen(initialNote: wordsToPush)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'voice_fab',
      onPressed: _isListening ? _stopListening : _startListening,
      backgroundColor: _isListening ? Colors.redAccent : Theme.of(context).cardTheme.color,
      foregroundColor: _isListening ? Colors.white : Theme.of(context).colorScheme.primary,
      elevation: _isListening ? 12 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 28)
        .animate(target: _isListening ? 1 : 0)
        .scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 300.ms, curve: Curves.easeInOut)
        .tint(color: Colors.white, duration: 300.ms),
    );
  }
}
