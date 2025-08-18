import 'package:flutter/material.dart';
import 'policy_screen.dart';
import 'payment_screen.dart';
import 'home_page.dart';
import 'utils/shared_preferences.dart';
import 'help_intro_screen.dart';
import 'trial_ended_screen.dart';
import 'paid_ended_screen.dart'; // <-- Added
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final accepted = await PreferenceService.getAcceptedPolicies();
    if (!accepted) {
      _navigateTo(const PolicyScreen());
      return;
    }

    // Use new centralized logic
    final status = await PreferenceService.getSubscriptionStatus();

    switch (status) {
      case SubscriptionStatus.notRegistered:
        _navigateTo(const PaymentScreen());
        break;
      case SubscriptionStatus.trialActive:
      case SubscriptionStatus.paidActive:
        _showNextScreen();
        break;
      case SubscriptionStatus.trialExpired:
        _navigateTo(const TrialEndedScreen());
        break;
      case SubscriptionStatus.paidExpired:
        _navigateTo(const PaidEndedScreen()); // <-- Was SubscribeScreen, now PaidEndedScreen
        break;
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return; // <--- Added safety check
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _showNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final showHelp = prefs.getBool('showHelpOnStartup') ?? false;
    if (!mounted) return; // <--- Added safety check
    if (!showHelp) {
      _navigateTo(const HomePage());
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (introContext) => IntroHelpScreen(
            onContinue: () {
              Navigator.pushReplacement(
                introContext,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // While access checks run, show a dark blue background
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: const SizedBox.shrink(),
    );
  }
}