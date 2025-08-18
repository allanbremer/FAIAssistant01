import 'package:flutter/material.dart';
import 'openai_service.dart'; // Import the helper class

class AIAnswerPage extends StatefulWidget {
  final String formName;
  final int fieldNumber;
  final String question;
  final String fieldLabel;

  const AIAnswerPage({
    super.key,
    required this.formName,
    required this.fieldNumber,
    required this.question,
    required this.fieldLabel,
  });

  @override
  State<AIAnswerPage> createState() => _AIAnswerPageState();
}

class _AIAnswerPageState extends State<AIAnswerPage> {
  String? _answer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnswer();
  }

  Future<void> _fetchAnswer() async {
    final prompt = widget.question;
    final aiAnswer = await OpenAIService.getAIAnswer(prompt);
    setState(() {
      _answer = aiAnswer;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Image.asset(
              'assets/images/ai_icon.png',
              height: 120,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        _answer ?? 'No answer received.',
                        style: const TextStyle(fontSize: 18, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Return to ${widget.fieldLabel}'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                  child: Text(
                    "Disclaimer: AI-generated answers are paraphrased for educational purposes and are not official AS9102 specification text. For exact requirements, refer to the licensed AS9102 standard.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}