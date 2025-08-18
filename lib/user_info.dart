import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fai_assistant/help_intro_screen.dart';
import 'package:fai_assistant/payment_screen.dart'; // import payment screen here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'icon_help_screen.dart';
import 'help_text_screen.dart';
import 'home_page.dart';

class UserInfoScreen extends StatefulWidget {
  final bool isPaid;
  const UserInfoScreen({Key? key, this.isPaid = false}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isNameValid = false;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_validate);
    _emailCtrl.addListener(_validate);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_validate);
    _emailCtrl.removeListener(_validate);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    setState(() {
      _isNameValid = name.isNotEmpty;
      _isEmailValid = emailOk;
    });
  }

  Future<void> _handleContinue() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (!_isNameValid || !_isEmailValid) {
      if (!mounted) return; // <-- Add this check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and email.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'email': email,
        'isPaid': widget.isPaid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return; // <-- Add this check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to server: $e')),
      );
      return;
    }

    if (!mounted) return; // <-- Add this check before navigating

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (helpCtx) => IntroHelpScreen(
          onContinue: () {
            Navigator.pushReplacement(
              helpCtx,
              MaterialPageRoute(builder: (_) => const HomePage()),  // <-- Changed here
            );
          },
        ),
      ),
    );
  }

  void _showIconHelp() {
    showDialog(
      context: context,
      builder: (_) => IconHelpScreen(
        helpText: HelpText.texts['user_info_icon'] ?? 'Enter your name and email here.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _isNameValid && _isEmailValid;

    return Scaffold(
      resizeToAvoidBottomInset: true, // allows keyboard to push up content
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        toolbarHeight: 56,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Your Info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: InkWell(
          onTap: _showIconHelp,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Image.asset(
              'assets/images/fai_assistant_app_icon.png',
              width: 36,
              height: 36,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: canContinue ? _handleContinue : null,
                child: Text(widget.isPaid ? 'Pay & Continue' : 'Continue'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // If no previous screen, go back to payment screen explicitly
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentScreen()),
                      );
                    }
                  },
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}