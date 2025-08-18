import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fai_assistant/help_text_screen.dart';

/// Screen shown on first launch (or manually invoked) to give an introduction.
class IntroHelpScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const IntroHelpScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<IntroHelpScreen> createState() => _IntroHelpScreenState();
}

class _IntroHelpScreenState extends State<IntroHelpScreen> {
  bool doNotShowAgain = false;

  Future<void> _onContinue() async {
    if (doNotShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showHelpOnStartup', false);
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final introText = HelpText.texts[HelpKeys.intro] ?? 'Welcome to FAI Assistant!';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        title: const Text(
          "Welcome!",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable content: icon and help text with visible scrollbar
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/fai_assistant_app_icon.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          introText,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer: checkbox and OK button stay visible
              Row(
                children: [
                  Checkbox(
                    value: doNotShowAgain,
                    onChanged: (val) => setState(() => doNotShowAgain = val!),
                  ),
                  const Expanded(child: Text("Don't show this again")),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}