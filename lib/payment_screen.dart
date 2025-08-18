import 'package:flutter/material.dart';
import 'utils/shared_preferences.dart';
import 'user_info.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

class PaymentScreen extends StatefulWidget {
  final bool showFreePlan;
  const PaymentScreen({super.key, this.showFreePlan = true});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedOption = 'free';

  @override
  void initState() {
    super.initState();
    // If we are NOT showing the free plan, force the selection to 'year'
    if (!widget.showFreePlan) {
      selectedOption = 'year';
    }
  }

  void _goToUserInfoScreen(bool isPaidUser) async {
    await PreferenceService.setSubscriptionType(selectedOption);
    await PreferenceService.setIsRegistered(true);
    // record paid vs. free for later checks
    await PreferenceService.setIsPaid(isPaidUser);

    if (!isPaidUser) {
      await PreferenceService.setTrialStartDate(DateTime.now());
    } else {
      await PreferenceService.setSubscriptionStartDate(DateTime.now());
    }

    if (!mounted) return;  // <----- FIX: add this line

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserInfoScreen(isPaid: isPaidUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // --- ICON WITH SHADOW (NO TAP)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/fai_assistant_app_icon.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- APP NAME
                  const Text(
                    'Your FAI Assistant',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // --- BENEFIT STATEMENTS
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Enjoy your first 7 days - it\'s free')]),
                      SizedBox(height: 10),
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Cancel anytime in-app or account')]),
                      SizedBox(height: 10),
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Free Updates and no ads, ever!')]),
                      SizedBox(height: 10),
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Approve FAI\'s with confidence')]),
                      SizedBox(height: 10),
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Built for real-world FAI challenges')]),
                      SizedBox(height: 10),
                      Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 8), Text('Add AS9102 PDF for full reference')]),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- DIVIDER BETWEEN BENEFITS AND PLANS
                  const Divider(thickness: 1, color: Colors.indigoAccent, height: 32),
                  const SizedBox(height: 12),

                  // --- PLAN CHOICES WITH ANIMATION & POLISHED COLORS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.showFreePlan)
                        _buildOptionBox('Free', '7 days', 'free'),
                      _buildOptionBox('1 Year', '\$39.99', 'year'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- PRICING SENTENCE (WORDING TWEAKED)
                  Text(
                    widget.showFreePlan
                        ? '7 days free, then only \$39.99/yr (\$3.33/mo)'
                        : 'Renew now for just \$39.99/year (\$3.33/month)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // --- CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedOption == 'free' && widget.showFreePlan) {
                          _goToUserInfoScreen(false);
                        } else if (selectedOption == 'year') {
                          _goToUserInfoScreen(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a plan.')),
                          );
                        }
                      },
                      child: const Text('Continue'),
                    ),
                  ),

                  // --- DEV-ONLY: Skip User Info button ---
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Dev: Skip User Info'),
                        onPressed: () async {
                          await PreferenceService.setSubscriptionType(selectedOption);
                          await PreferenceService.setIsRegistered(true);
                          await PreferenceService.setIsPaid(selectedOption == 'year');
                          if (selectedOption == 'free' && widget.showFreePlan) {
                            await PreferenceService.setTrialStartDate(DateTime.now());
                          } else {
                            await PreferenceService.setSubscriptionStartDate(DateTime.now());
                          }
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Animated, Polished Option Box
  Widget _buildOptionBox(String title, String subtitle, String value) {
    final isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () {
        setState(() => selectedOption = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.indigo : Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.indigo.shade100 : Colors.grey[50],
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.10),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: value,
                  groupValue: selectedOption,
                  onChanged: (val) => setState(() => selectedOption = val!),
                ),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}