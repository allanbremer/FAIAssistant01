import 'package:flutter/material.dart';
import 'dart:math';
import 'help_screen.dart';

class RightTrianglePage extends StatefulWidget {
  const RightTrianglePage({super.key});

  @override
  State<RightTrianglePage> createState() => _RightTrianglePageState();
}

class _RightTrianglePageState extends State<RightTrianglePage> {
  final sideAController = TextEditingController();
  final sideBController = TextEditingController();
  final sideCController = TextEditingController();
  final angleAController = TextEditingController();
  final angleBController = TextEditingController();

  void calculateTriangle() {
    FocusScope.of(context).unfocus();

    double? a = double.tryParse(sideAController.text);
    double? b = double.tryParse(sideBController.text);
    double? c = double.tryParse(sideCController.text);
    double? angleA = double.tryParse(angleAController.text);
    double? angleB = double.tryParse(angleBController.text);

    try {
      int known = [a, b, c, angleA, angleB].where((v) => v != null).length;
      if (known < 2) throw Exception('Enter at least two known values.');

      double? angleARad = angleA != null ? angleA * pi / 180 : null;
      double? angleBRad = angleB != null ? angleB * pi / 180 : null;

      // 1. a and b
      if (a != null && b != null) {
        c = sqrt(a * a + b * b);
        angleARad = asin(a / c);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 2. a and c
      else if (a != null && c != null) {
        if (c <= a) throw Exception('Hypotenuse must be longest side.');
        b = sqrt(c * c - a * a);
        angleARad = asin(a / c);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 3. a and angle B
      else if (a != null && angleBRad != null) {
        c = a / cos(angleBRad);
        b = sqrt(c * c - a * a);
        angleARad = asin(a / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 4. a and angle A
      else if (a != null && angleARad != null) {
        c = a / sin(angleARad);
        b = sqrt(c * c - a * a);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 5. b and c
      else if (b != null && c != null) {
        if (c <= b) throw Exception('Hypotenuse must be longest side.');
        a = sqrt(c * c - b * b);
        angleARad = asin(a / c);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 6. b and angle A
      else if (b != null && angleARad != null) {
        c = b / cos(angleARad);
        a = sqrt(c * c - b * b);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 7. b and angle B
      else if (b != null && angleBRad != null) {
        c = b / sin(angleBRad);
        a = sqrt(c * c - b * b);
        angleARad = asin(a / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 8. c and angle A
      else if (c != null && angleARad != null) {
        a = c * sin(angleARad);
        b = sqrt(c * c - a * a);
        angleBRad = asin(b / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      }
      // 9. c and angle B
      else if (c != null && angleBRad != null) {
        b = c * sin(angleBRad);
        a = sqrt(c * c - b * b);
        angleARad = asin(a / c);
        angleA = angleARad * 180 / pi;
        angleB = angleBRad * 180 / pi;
      } else {
        throw Exception('Unsupported combination. Use two related values.');
      }

      // Update fields
      setState(() {
        sideAController.text = a!.toStringAsFixed(3);
        sideBController.text = b!.toStringAsFixed(3);
        sideCController.text = c!.toStringAsFixed(3);
        angleAController.text = angleA!.toStringAsFixed(2);
        angleBController.text = angleB!.toStringAsFixed(2);
      });
    } catch (e) {
      clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void clearFields() {
    setState(() {
      sideAController.clear();
      sideBController.clear();
      sideCController.clear();
      angleAController.clear();
      angleBController.clear();
    });
  }

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
                builder: (_) => const HelpScreen(helpKey: 'right_triangle'),
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
        title: const Text('Right Triangle Calculator'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Image.asset(
                    'assets/images/trig.png',
                    height: 120,
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Side a', sideAController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Side b', sideBController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Hypot. c', sideCController)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Angle A (°)', angleAController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Angle B (°)', angleBController)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFixedButton('Back', () => Navigator.pop(context)),
                    _buildFixedButton('Calc', calculateTriangle),
                    _buildFixedButton('Clear', clearFields),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
    );
  }

  Widget _buildFixedButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    sideAController.dispose();
    sideBController.dispose();
    sideCController.dispose();
    angleAController.dispose();
    angleBController.dispose();
    super.dispose();
  }
}