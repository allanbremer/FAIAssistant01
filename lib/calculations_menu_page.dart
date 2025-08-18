import 'package:flutter/material.dart';
import '/screens/position_and_bonus_page.dart';
import 'right_triangle_page.dart';
import 'package:fai_assistant/help_screen.dart';
import 'package:fai_assistant/help_text_screen.dart';

class CalculationsMenuPage extends StatelessWidget {
  const CalculationsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpScreen(helpKey: HelpKeys.calculationsMenu),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/fai_assistant_app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text('Calculations'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // App icon
                      Center(
                        child: Image.asset(
                          'assets/images/fai_assistant_app_icon.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Buttons area centered vertically
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _menuButton(
                              context,
                              label: 'True Position & Bonus Tolerance Calculator',
                              page: const PositionAndBonusPage(),
                            ),
                            const SizedBox(height: 20),
                            _menuButton(
                              context,
                              label: 'Trigonometry Calculator',
                              page: const RightTrianglePage(),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Go Back button pinned to bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              minimumSize: const Size(200, 48),
                            ),
                            child: const Text('Go Back', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, {required String label, required Widget page}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}