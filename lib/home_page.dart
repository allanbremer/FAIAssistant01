// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'abbreviation_page.dart';
import 'form1_page.dart';
import 'form2_page.dart';
import 'form3_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'specs_page.dart';
import 'calculations_menu_page.dart';
import 'icon_help_screen.dart';
import 'package:fai_assistant/screens/documents_page.dart';
import 'package:fai_assistant/screens/certifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_text_screen.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'utils/shared_preferences.dart';   // For PreferenceService.resetAll()
import 'payment_screen.dart';             // Dev tool routing
import 'trial_ended_screen.dart';         // Dev tool routing
import 'paid_ended_screen.dart';          // Dev tool routing

// NEW: wire to the real View Notes flow
import 'view_notes.dart';

// NEW: use NoteStore + NoteTypes for saving Company Notes
import 'note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String iconPath = 'assets/images/fai_assistant_app_icon.png';

  bool _form1HasNote = false;
  bool _form2HasNote = false;
  bool _form3HasNote = false;

  // --- Coachmark (one-time tip) state ---
  final GlobalKey _homeIconKey = GlobalKey();
  OverlayEntry? _companyCoachmark;
  bool _coachmarkInserted = false;

  @override
  void initState() {
    super.initState();
    _refreshAllNoteFlags();
    _maybeShowCompanyCoachmark(); // show one-time tip after first layout
  }

  Future<void> _refreshAllNoteFlags() async {
    final prefs = await SharedPreferences.getInstance();
    bool scan(String formName, int count) {
      for (var i = 1; i <= count; i++) {
        if ((prefs.getString('notes_${formName}_Field$i') ?? '').isNotEmpty) {
          return true;
        }
      }
      return false;
    }

    setState(() {
      _form1HasNote = scan('Form 1', 26);
      _form2HasNote = scan('Form 2', 13);
      _form3HasNote = scan('Form 3', 12);
    });
  }

  // --- DEV: State Chooser Dialog ---
  Future<void> _showDevStateDialog() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set App State (Dev Only)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Brand New User'),
              onPressed: () async {
                await PreferenceService.resetAll();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  (route) => false,
                );
              },
            ),
            ElevatedButton(
              child: const Text('Active Trial'),
              onPressed: () async {
                await PreferenceService.resetAll();
                await PreferenceService.setIsRegistered(true);
                await PreferenceService.setSubscriptionType('free');
                await PreferenceService.setTrialStartDate(DateTime.now());
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
            ),
            ElevatedButton(
              child: const Text('Expired Trial'),
              onPressed: () async {
                await PreferenceService.resetAll();
                await PreferenceService.setIsRegistered(true);
                await PreferenceService.setSubscriptionType('free');
                await PreferenceService.setTrialStartDate(
                  DateTime.now().subtract(const Duration(days: 8)));
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const TrialEndedScreen()),
                  (route) => false,
                );
              },
            ),
            ElevatedButton(
              child: const Text('Active Paid'),
              onPressed: () async {
                await PreferenceService.resetAll();
                await PreferenceService.setIsRegistered(true);
                await PreferenceService.setIsPaid(true);
                await PreferenceService.setSubscriptionType('year');
                await PreferenceService.setSubscriptionStartDate(DateTime.now());
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
            ),
            ElevatedButton(
              child: const Text('Expired Paid'),
              onPressed: () async {
                await PreferenceService.resetAll();
                await PreferenceService.setIsRegistered(true);
                await PreferenceService.setIsPaid(true);
                await PreferenceService.setSubscriptionType('year');
                await PreferenceService.setSubscriptionStartDate(
                  DateTime.now().subtract(const Duration(days: 366)));
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PaidEndedScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _onPurchaseAS9102Pressed() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase AS9102'),
        content: const Text(
          'This will take you to the official SAE website where you can purchase the AS9102 specification or find more information about the standard and SAE.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Go Back
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              const url = 'https://www.sae.org/standards/content/as9102c/';
              final uri = Uri.parse(url);
              final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!ok) {
                final ok2 = await launchUrl(uri, mode: LaunchMode.platformDefault);
                if (!ok2 && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open SAE website')),
                  );
                }
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // UPDATED: View Notes handler now routes to real ViewNotesPage
  void _onViewNotesPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViewNotesPage()),
    );
  }

  // -------- One-time coachmark logic --------
  Future<void> _maybeShowCompanyCoachmark() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('company_coachmark_shown') ?? false;
    if (shown) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showCompanyCoachmark();
      await prefs.setBool('company_coachmark_shown', true);
    });
  }

  void _showCompanyCoachmark() {
    if (!mounted || _coachmarkInserted) return;

    final overlay = Overlay.of(context);
    final renderBox = _homeIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || renderBox == null) return;

    final iconSize = renderBox.size;
    final iconPos = renderBox.localToGlobal(Offset.zero);

    _companyCoachmark = OverlayEntry(
      builder: (ctx) {
        // Position bubble above the icon with a small arrow
        const bubbleWidth = 260.0;
        final bubbleTop = iconPos.dy - 80;
        final bubbleLeft =
            (iconPos.dx + iconSize.width / 2) - (bubbleWidth / 2);

        return Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissCompanyCoachmark,
              ),
            ),
            Positioned(
              left: bubbleLeft.clamp(
                12.0,
                MediaQuery.of(ctx).size.width - bubbleWidth - 12.0,
              ),
              top: bubbleTop.clamp(
                12.0,
                MediaQuery.of(ctx).size.height - 140.0,
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bubble
                    Container(
                      width: bubbleWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Insert a Company Note here by long-pressing this Home Icon',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Arrow (down triangle)
                    ClipPath(
                      clipper: _DownTriangleClipper(),
                      child: Container(
                        width: 18,
                        height: 10,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_companyCoachmark!);
    _coachmarkInserted = true;
  }

  void _dismissCompanyCoachmark() {
    _companyCoachmark?.remove();
    _companyCoachmark = null;
    _coachmarkInserted = false;
  }

  // -------- Quick add Company Note (long-press) --------
  Future<void> _quickAddCompanyNote(BuildContext context) async {
    final draft = await showModalBottomSheet<_CompanyNoteDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CompanyNoteQuickAddSheet(),
    );
    if (draft == null) return;

    final store = NoteStore();
    await store.add(
      fieldKey: 'Company_General', // neutral bucket
      title: draft.title,
      body: 'Company: ${draft.company}\n\n${draft.body}',
      noteType: NoteTypes.company, // make sure NoteTypes.company exists
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company note saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add a little extra bottom cushion beyond the device’s safe-area inset
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double bottomCushion = safeBottom + 8; // nudge up “a few pixels”

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue[100]),
              child: const Text('Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'FAI Assistant',
                  applicationVersion: 'v1.0.0',
                  applicationLegalese: '© 2025 Aerospace QA Solutions LLC',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'FAI Assistant helps quality teams, suppliers, and inspectors confidently complete AS9102 First Article Inspection forms with clarity and speed. It provides field-by-field guidance, AI-powered support, and easy access to essential references.',
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        // EXACT URL REQUIRED
                        final uri = Uri.parse('https://faiassistant.com');
                        // Try external app first, then platform default as fallback.
                        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!ok) {
                          final ok2 = await launchUrl(uri, mode: LaunchMode.platformDefault);
                          if (!ok2 && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open faiassistant.com')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Visit https://faiassistant.com',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Updates'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No updates available')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Version'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Version: 1.0.0')),
                );
              },
            ),
            // ----------- The Delete AS9102 menu option is now removed -----------
          ],
        ),
      ),

      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
      ),

      // ---- DEV-ONLY STATE TOOL BUTTON, only visible in debug mode ----
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              heroTag: 'dev-reset',
              tooltip: 'Dev State Tool (Debug Only)',
              backgroundColor: Colors.redAccent,
              onPressed: _showDevStateDialog,
              child: const Icon(Icons.refresh),
            )
          : null,

      // Wrap the scrollable content in SafeArea so the last button isn’t glued to the edge
      body: SafeArea(
        top: false, // keep the AppBar flush at the top
        bottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomCushion),
          children: [
            Center(
              child: GestureDetector(
                key: _homeIconKey, // anchor for the coachmark
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IconHelpScreen(
                        helpText: HelpText.texts[HelpKeys.homePage] ?? '',
                      ),
                    ),
                  );
                },
                onLongPress: () => _quickAddCompanyNote(context), // NEW
                child: Image.asset(
                  iconPath,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const Form1Page()))
                            .then((_) => _refreshAllNoteFlags());
                      },
                      child: Text('FORM 1${_form1HasNote ? ' *' : ''}'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const Form2Page()))
                            .then((_) => _refreshAllNoteFlags());
                      },
                      child: Text('FORM 2${_form2HasNote ? ' *' : ''}'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const Form3Page()))
                            .then((_) => _refreshAllNoteFlags());
                      },
                      child: Text('FORM 3${_form3HasNote ? ' *' : ''}'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              {'label': 'DOCUMENTS', 'route': const DocumentListPage()},
              {'label': 'CERTIFICATIONS', 'route': const CertificationListPage()},
              {'label': 'SPECIFICATIONS', 'route': const SpecsPage()},{'label': 'CALCULATIONS', 'route': const CalculationsMenuPage()},
              {'label': 'ABBREVIATIONS', 'route': const AbbreviationPage()},
            ].map((topic) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => topic['route'] as Widget),
                      );
                    },
                    child: Text(topic['label'] as String),
                  ),
                ),
              );
            }).toList(),
            // Bottom section: VIEW NOTES + PURCHASE (lifted above bottom)
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onViewNotesPressed,
                        child: const Text('VIEW NOTES'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12), // lifts off bottom
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onPurchaseAS9102Pressed,
                        child: const Text('PURCHASE AS9102'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Helpers for coachmark arrow ----------
class _DownTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width / 2, size.height);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---------- Quick-add Company Note sheet ----------
class _CompanyNoteDraft {
  final String company;
  final String title;
  final String body;
  const _CompanyNoteDraft(this.company, this.title, this.body);
}

class CompanyNoteQuickAddSheet extends StatefulWidget {
  const CompanyNoteQuickAddSheet({super.key});

  @override
  State<CompanyNoteQuickAddSheet> createState() => _CompanyNoteQuickAddSheetState();
}

class _CompanyNoteQuickAddSheetState extends State<CompanyNoteQuickAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'New Company Note',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyCtrl,
              decoration: const InputDecoration(
                labelText: 'Company *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Company is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyCtrl,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.pop(
                        context,
                        _CompanyNoteDraft(
                          _companyCtrl.text.trim(),
                          _titleCtrl.text.trim(),
                          _bodyCtrl.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}