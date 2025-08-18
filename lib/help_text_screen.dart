// help_text_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Keys identifying each help section. Use these to look up the corresponding text.
class HelpKeys {
  static const String intro           = 'help_intro';
  static const String rightTriangle   = 'right_triangle';
  static const String calcMenu        = 'help_calculations_menu';
  static const String specsPage       = 'specPage';
  static const String abbrevPage      = 'abbrevPage';
  static const String documentsPage   = 'documentsPage';
  static const String form1Page       = 'form1Page';
  static const String form2Page       = 'form2Page';
  static const String form3Page       = 'form3Page';
  static const String homePage        = 'homePage';
  static const String as9102InfoPage  = 'as9102InfoPage';
  static const String policyScreen    = 'policyScreen';
  static const String termsOfUse      = 'termsOfUse';
  static const String privacyPolicy   = 'privacyPolicy';
  static const String user_info_icon  = 'user_info_icon';
  static const String calculationsMenu = 'calculationsMenu';
  static const String checklistMenu    = 'checklistMenu';
  static const String checklistForm1    = 'checklistForm1';
  static const String checklistForm2    = 'checklistForm2';
  static const String checklistForm3    = 'checklistForm3';
  static const String certHelp    = 'certHelp';
  static const String noteHelp    = 'noteHelp';
  static const String get9102InfoPage = 'get9102InfoPage';
  static const String positionAndBonus = 'positionAndBonus';
  // Form 1 fields
  static const String form1Field1  = 'form1_field1';
  static const String form1Field2  = 'form1_field2';
  static const String form1Field3  = 'form1_field3';
  static const String form1Field4  = 'form1_field4';
  static const String form1Field5  = 'form1_field5';
  static const String form1Field6  = 'form1_field6';
  static const String form1Field7  = 'form1_field7';
  static const String form1Field8  = 'form1_field8';
  static const String form1Field9  = 'form1_field9';
  static const String form1Field10 = 'form1_field10';
  static const String form1Field11 = 'form1_field11';
  static const String form1Field12 = 'form1_field12';
  static const String form1Field13 = 'form1_field13';
  static const String form1Field14 = 'form1_field14';
  static const String form1Field15 = 'form1_field15';
  static const String form1Field16 = 'form1_field16';
  static const String form1Field17 = 'form1_field17';
  static const String form1Field18 = 'form1_field18';
  static const String form1Field19 = 'form1_field19';
  static const String form1Field20 = 'form1_field20';
  static const String form1Field21 = 'form1_field21';
  static const String form1Field22 = 'form1_field22';
  static const String form1Field23 = 'form1_field23';
  static const String form1Field24 = 'form1_field24';
  static const String form1Field25 = 'form1_field25';
  static const String form1Field26 = 'form1_field26';

  // Form 2 fields
  static const String form2Field1  = 'form2_field1';
  static const String form2Field2  = 'form2_field2';
  static const String form2Field3  = 'form2_field3';
  static const String form2Field4  = 'form2_field4';
  static const String form2Field5  = 'form2_field5';
  static const String form2Field6  = 'form2_field6';
  static const String form2Field7  = 'form2_field7';
  static const String form2Field8  = 'form2_field8';
  static const String form2Field9  = 'form2_field9';
  static const String form2Field10 = 'form2_field10';
  static const String form2Field11 = 'form2_field11';
  static const String form2Field12 = 'form2_field12';
  static const String form2Field13 = 'form2_field13';

  // Form 3 fields
  static const String form3Field1  = 'form3_field1';
  static const String form3Field2  = 'form3_field2';
  static const String form3Field3  = 'form3_field3';
  static const String form3Field4  = 'form3_field4';
  static const String form3Field5  = 'form3_field5';
  static const String form3Field6  = 'form3_field6';
  static const String form3Field7  = 'form3_field7';
  static const String form3Field8  = 'form3_field8';
  static const String form3Field9  = 'form3_field9';
  static const String form3Field10 = 'form3_field10';
  static const String form3Field11 = 'form3_field11';
  static const String form3Field12 = 'form3_field12';

  // Certification Page helps
  static const String certMaterial = 'certMaterial';
  static const String certProcess = 'certProcess';
  static const String certInk = 'certInk';
  static const String certFastener = 'certFastener';
  static const String certPaintPrimer = 'certPaintPrimer';
  static const String certCoating = 'certCoating';
  static const String certHeatTreat = 'certHeatTreat';
  static const String certHardnessConductivity = 'certHardnessConductivity';
  static const String certSurfaceTreatment = 'certSurfaceTreatment';
  static const String certTest = 'certTest';
  static const String certPlating = 'certPlating';
  static const String certPlug = 'certPlug';
  static const String certEpoxyBonding = 'certEpoxyBonding';
}

/// Centralized repository for all help text, looked up by HelpKeys.
class HelpText {
  static const Map<String, String> texts = {
    HelpKeys.intro: '''
FAI Assistant is built to work hand in hand with the official AS9102 specification. To take advantage of these features, you’ll need the as9102.pdf file available on your phone. Without the AS9102 file, all features of FAI Assistant are still fully functional except the AS9102 buttons will not be available. The as9102.pdf file must be purchased through SAE's website. FAI Assistant will validate the file for use before it implements into the app for use. FAI professional reviewers quickly recoup the investment of purchasing AS9102 by speeding up inspections, reducing costly errors, and maintaining perfect compliance.

Whenever you need guidance, help is just a tap away. Tap the blue app icon at the top left of most screens to pull up context sensitive help. You can also long press buttons and list items to take notes.

You’ve already taken the first step toward faster, more reliable First Article Inspections—congratulations! FAI Assistant is built to streamline your workflow every step of the way. Your accuracy, your customers, and your bottom line will thank you.
''',

    HelpKeys.specsPage: '''
This Specifications page is a good place to input your most important specifications. By tapping the (+) plus button at the bottom right your able to add a specification, a revision number, and then the description. FAI Assistant is loaded up with some default specifications for you to visualize how the input looks.

You can edit the specifications by tapping the Edit Pencil and delete them by tapping the Trashcan Icon.
''',

    HelpKeys.documentsPage: '''
Here is the Documents descriptions.
''',

    HelpKeys.checklistMenu: '''
Here is Checklist Menu Help.
''',

    HelpKeys.checklistForm1: '''
Here is Checklist Form 1 Help.
''',

    HelpKeys.checklistForm2: '''
Here is Checklist Form 2 Help.
''',

    HelpKeys.checklistForm3: '''
Here is Checklist Form 3 Help.
''',

    HelpKeys.get9102InfoPage: '''
Purchase AS9102 help text.
''',

    HelpKeys.as9102InfoPage: '''
To view the AS9102 Specification, please purchase it from the official SAE site:

https://www.sae.org/standards/content/as9102/

Then download the file and choose it using the button below. All AS9102 buttons will be unavailable without the as9102.pdf file being installed. Be sure the file is purchased through SAE and is named 'as9102.pdf' once it's on your phone.
''',

    HelpKeys.homePage: '''
Welcome to the FAI Assistant! Here you can access Forms, Checklists, Calculations, and more. Tap any button below to get started.
''',

    HelpKeys.form1Page: '''
Form 1: Part Number Accountability: This screen contains all the scrollable buttons of all 26 Fields of Form 1.
''',

    HelpKeys.form2Page: '''
Here is the form2 page descriptions.
''',

    HelpKeys.form3Page: '''
Here is the form3 page descriptions.
''',

    HelpKeys.certMaterial: '''
The certification for raw material must be included with the other documents in the FAI. Be aware that this is not only one document. The Material certifications range from packing slips, to test reports, certificates of Inspection and Conformance, raw material receipts, and lab reports.

Check for the allowance of substitute materials and whether or not the specifications allow it. Also, if the FAI is for a durability critical or a fracture critical part then each material document may have to specify that description. Be sure the material provider is an approved source by the company

Double check the addresses of Sold To and Ship To, review the size dimensions of the material. Verify that the Parts List and Supplier Specification Plan show the exact same material as the certification documents.

''',

    HelpKeys.certProcess: '''
description for Process Certifications.
''',

    HelpKeys.certInk: '''
description for Ink Certifications.
''',

    HelpKeys.certFastener: '''
description for Fastener Certifications.
''',

    HelpKeys.certPaintPrimer: '''
description for Paint/Primer Certifications.
''',

    HelpKeys.certCoating: '''
description for Coating Certifications.
''',

    HelpKeys.certHeatTreat: '''
description for Heat Treat Certifications.
''',

    HelpKeys.certHardnessConductivity: '''
description for Hardness/Conductivity Certifications.
''',

    HelpKeys.certSurfaceTreatment: '''
description for Surface Treatment Certifications.
''',

    HelpKeys.certTest: '''
description for Test Certifications.
''',

    HelpKeys.certPlating: '''
description for Plating Certifications.
''',

    HelpKeys.certPlug: '''
description for Plug Certifications.
''',

    HelpKeys.certEpoxyBonding: '''
description for Epoxy/Bonding Certifications.
''',

    HelpKeys.user_info_icon: '''
Input First and Last name and email here.
''',

    HelpKeys.certHelp: '''
Help with Certificates of Conformance. Add more to this on line 193.
''',

    HelpKeys.noteHelp: '''
Help with taking notes.
''',

    HelpKeys.abbrevPage: '''
These aerospace abbreviations can be very helpful when discussing business with other FAI reviewers and people in the industry. Many people in this industry use abbreviations when they are discussing FAI documentation, specifications, and all around aerospace jargon.

These abbreviations are automatically alphabetized when you input new items. When you delete an item you'll be prompted before its removal.
''',

    HelpKeys.positionAndBonus: '''
This calculator helps FAI reviewers validate True Position and Bonus Tolerances as they go through the CMM documents in order to double check Form 3 results. You may see a 'Failed' result in Form 3 along with a note mentioning that it actually passes because of the Bonus Tolerance. This calculator will help you verify that.

This calculator computes position at MMC for not only holes but also for pins. You can enter the MMC size directly by getting it from the CMM report or you can enter the nominal size along with its plus and minus tolerances and get the MMC from that input. Just remember that MMC is the smallest size allowable hole and the largest size allowable pin.

You can get the X and Y deviations from zero and obtain true position that way, that's called 2D True Position. You can also look into a CMM report and get X, Y, and Z to obtain actual 3D True Position. The CMM report will have all that information. Always be aware that it is possible for CMM reports to be manipulated. You can always use this calculator if something feels or looks wrong in a CMM report or on Form 3.

You can choose to input the MMC size directly from the CMM report or you can let the calculator figure out the MMC by giving it the hole size (Nominal Size), the upper tolerance limit, and the lower tolerance limit.

Where this True Position and Bonus Tolerance calculator really shines is in the Export to PDF function. You can choose to print it out or create the file on your phone. You can generate a report that includes the FAI number, the part number, the character number on form 3, and also your name. Once you choose to print or create the PDF report, you'll have the option to also include Notes.

Here are some definitions:
MMC (Maximum Material Condition): The size where the feature contains the most material.
    Hole: smallest permissible size.
    Pin : largest permissible size.
  
Bonus tolerance: Extra geometric tolerance you get when the actual size is away from MMC (toward LMC). LMC is Least Material Condition.

Available positional tolerance
    Available TP = FCF tol @ MMC + Bonus: FCF (Feature Control Frame)
  True position (measured)
    2D: TP(⌀) = 2 × √(X² + Y²)
    3D: TP(⌀) = 2 × √(X² + Y² + Z²)
  PASS/FAIL
    PASS if Measured TP(⌀) ≤ Available TP

  Lower tolerance sign convention when deriving MMC:
    Hole: lower tolerance is negative (e.g., −0.001)
    Pin : upper tolerance is positive (e.g., +0.002)
  The calculator enforces these signs internally.

Input modes
1) Enter MMC size directly
     Type the MMC size (e.g., a hole’s smallest allowable diameter).
2) Derive MMC from Nominal ± Tolerances
     Enter Nominal, Upper tolerance (+), and Lower tolerance (−).
     For holes, lower tolerance is treated as negative; for pins, upper tol is positive.
3) Location input
   a) X/Y deviations
        Enter absolute deviations. You can optionally include Z:
          2D: TP(⌀) = 2 × √(X² + Y²)
          3D: TP(⌀) = 2 × √(X² + Y² + Z²)
        Use the CMM’s full precision values (rounding changes results).
   b) Measured TP (diameter)
        Enter the CMM’s measured true position (diameter) directly.

Units
  Choose inches (in) or millimeters (mm). All inputs/outputs use the selected unit.

Report fields (PDF)
  Identity: FAI, PN, Char. No., Name, Notes
  Inputs: Feature type, Units, Nominal, Tol (+ / −), MMC, Actual size, FCF Pos Tol, Datums, X/Y[/Z] dev, Measured TP (⌀)
  Results: Bonus, Available TP, Measured TP (⌀), Margin
  Formula line reflects 2D or 3D automatically (adds +Z² when Z is provided).

Examples
Hole example with 3D TP:
  Nominal 0.314, Lower tol −0.001 → MMC 0.313
  Actual 0.3149 → Bonus 0.0019
  FCF @ MMC 0.005 → Available TP 0.0069
  X = −0.0001, Y = 0.0030, Z = −0.0008
  r = √(0.0001² + 0.0030² + 0.0008²) = 0.003106445…
  TP(⌀) = 2 × r = 0.00621289…
  PASS, Margin ≈ 0.000687

Tips to match CMM
  Enter X/Y/Z with full precision (4–6+ decimals).
  Confirm whether your CMM reports 2D or 3D true position.
  Ensure datum alignment/basics match the CMM setup.

Troubleshooting
  If results differ from the CMM:
    Check that lower/upper tolerance signs are correct.
    Use the CMM’s exact X/Y/Z or directly enter the Measured TP (⌀).
''',

    HelpKeys.rightTriangle: '''
Right Triangle calculations allow you to solve for missing sides or angles when you provide at least two valid values.

• Input can be in inches or mm for sides, and decimal degrees for angles.
• The calculator auto‑populates all fields once two inputs are provided.
''',

    HelpKeys.calcMenu: '''
On the Calculations screen you can:
• Select Bonus Tolerance to compute positional bonus.
• Select True Position to measure composite tolerance.
• Select Right Triangle to solve triangle dimensions.
''',

    HelpKeys.calculationsMenu: '''
On the Calculations screen you can:
• Select the True Position/Bonus Tolerance Calculator. Be sure to take advantage of the help icon at the upper left, the help text will not only help you to understand the input lines but it may help you understand more about True Position and Bonus Tolerance.
• Select the Right Triangle Calculator to solve right triangle dimensions. When your there, be sure to tap the top left help icon to learn more about it.
''',

    // --- Form 1 Field Help ---
    HelpKeys.form1Field1:  'Form 1 / Field 1 Help',
    HelpKeys.form1Field2:  'Form 1 / Field 2 Help',
    HelpKeys.form1Field3:  'Form 1 / Field 3 Help',
    HelpKeys.form1Field4:  'Form 1 / Field 4 Help',
    HelpKeys.form1Field5:  'Form 1 / Field 5 Help',
    HelpKeys.form1Field6:  'Form 1 / Field 6 Help',
    HelpKeys.form1Field7:  'Form 1 / Field 7 Help',
    HelpKeys.form1Field8:  'Form 1 / Field 8 Help',
    HelpKeys.form1Field9:  'Form 1 / Field 9 Help',
    HelpKeys.form1Field10: 'Form 1 / Field 10 Help',
    HelpKeys.form1Field11: 'Form 1 / Field 11 Help',
    HelpKeys.form1Field12: 'Form 1 / Field 12 Help',
    HelpKeys.form1Field13: 'Form 1 / Field 13 Help',
    HelpKeys.form1Field14: 'Form 1 / Field 14 Help',
    HelpKeys.form1Field15: 'Form 1 / Field 15 Help',
    HelpKeys.form1Field16: 'Form 1 / Field 16 Help',
    HelpKeys.form1Field17: 'Form 1 / Field 17 Help',
    HelpKeys.form1Field18: 'Form 1 / Field 18 Help',
    HelpKeys.form1Field19: 'Form 1 / Field 19 Help',
    HelpKeys.form1Field20: 'Form 1 / Field 20 Help',
    HelpKeys.form1Field21: 'Form 1 / Field 21 Help',
    HelpKeys.form1Field22: 'Form 1 / Field 22 Help',
    HelpKeys.form1Field23: 'Form 1 / Field 23 Help',
    HelpKeys.form1Field24: 'Form 1 / Field 24 Help',
    HelpKeys.form1Field25: 'Form 1 / Field 25 Help',
    HelpKeys.form1Field26: 'Form 1 / Field 26 Help',

    // --- Form 2 Field Help ---
    HelpKeys.form2Field1:  'Form 2 / Field 1 Help',
    HelpKeys.form2Field2:  'Form 2 / Field 2 Help',
    HelpKeys.form2Field3:  'Form 2 / Field 3 Help',
    HelpKeys.form2Field4:  'Form 2 / Field 4 Help',
    HelpKeys.form2Field5:  'Form 2 / Field 5 Help',
    HelpKeys.form2Field6:  'Form 2 / Field 6 Help',
    HelpKeys.form2Field7:  'Form 2 / Field 7 Help',
    HelpKeys.form2Field8:  'Form 2 / Field 8 Help',
    HelpKeys.form2Field9:  'Form 2 / Field 9 Help',
    HelpKeys.form2Field10: 'Form 2 / Field 10 Help',
    HelpKeys.form2Field11: 'Form 2 / Field 11 Help',
    HelpKeys.form2Field12: 'Form 2 / Field 12 Help',
    HelpKeys.form2Field13: 'Form 2 / Field 13 Help',

    // --- Form 3 Field Help ---
    HelpKeys.form3Field1:  'Form 3 / Field 1 Help',
    HelpKeys.form3Field2:  'Form 3 / Field 2 Help',
    HelpKeys.form3Field3:  'Form 3 / Field 3 Help',
    HelpKeys.form3Field4:  'Form 3 / Field 4 Help',
    HelpKeys.form3Field5:  'Form 3 / Field 5 Help',
    HelpKeys.form3Field6:  'Form 3 / Field 6 Help',
    HelpKeys.form3Field7:  'Form 3 / Field 7 Help',
    HelpKeys.form3Field8:  'Form 3 / Field 8 Help',
    HelpKeys.form3Field9:  'Form 3 / Field 9 Help',
    HelpKeys.form3Field10: 'Form 3 / Field 10 Help',
    HelpKeys.form3Field11: 'Form 3 / Field 11 Help',
    HelpKeys.form3Field12: 'Form 3 / Field 12 Help',

    HelpKeys.policyScreen: '''
This app is intended for educational purposes. It does not guarantee that your FAI documentation will be complete, accurate, or compliant with customer or industry requirements. Users should always confirm FAI requirements with their customer, quality team, regulatory documents and most of all, the AS9102 standard.

FAI Assistant is designed to provide educational assistance and research support related to First Article Inspection (FAI) processes. FAI Assistant is not a substitute for the AS9102 Rev. C specification, formal training, regulatory compliance, or professional judgement.

Disclaimer: The information provided within FAI Assistant is based on personal experience and interpretation of First Article Inspection (FAI) practices, developed over many years in the aerospace industry. While every effort has been made to ensure accuracy and usefulness, the content may not align with the specific requirements of the AS9102 Rev. C specifiction or expectations of all companies, auditors, or internal procedures. This app is intended as a helpful educational tool, not as a definitive or official source of AS9102 compliance. Always refer to your customer requirements and company-specific documentation when completing FAI forms.
''',

    HelpKeys.termsOfUse: '''
Terms of Use

Effective Date: June 15, 2025

Welcome to FAI Assistant. These Terms of Use ("Terms") govern your use of the FAI Assistant mobile application (the "App"). By using this App, you agree to be bound by these Terms. If you do not agree, do not use the App.

1. Purpose of the App:
FAI Assistant is designed to provide educational assistance and research support related to First Article Inspection (FAI) processes. The App is not a substitute for formal training, regulatory compliance, or professional judgment. It is a supplemental tool to help users understand how to properly complete AS9102 First Article Inspection forms.

2. No Guarantee of Compliance or Perfection:
The App does not guarantee that your First Article Inspection (FAI) documentation will be complete, accurate, or compliant with customer or industry requirements. The developer assumes no responsibility for inspection errors, missing information, or consequences arising from your use of the App.

3. Educational Use Only:
This App is intended for educational purposes. It is not a certifying authority, regulatory body, or legal source for compliance. Users should always confirm FAI requirements with their customer, quality team, or regulatory documents, but most of all, with the AS9102 Standard.

4. User Responsibility:
You are solely responsible for verifying the accuracy of the information you enter into the App and for the results of your inspections or documentation.

5. Intellectual Property:
All logos, content, and visual elements in the App are the property of the developer. You may not copy, modify, distribute, or republish any part of the App without written permission.

6. Modifications:
The developer reserves the right to update or modify these Terms at any time. Continued use of the App after such changes constitutes your acceptance of the new Terms.

7. Termination:
We may suspend or terminate your access to the App at our discretion, without notice, for behavior deemed abusive, illegal, or in violation of these Terms.

8. Limitation of Liability:
The App is provided “as is” without warranties of any kind. In no event shall the developer be liable for any damages arising out of your use of, or inability to use, the App.

9. Governing Law:
These Terms shall be governed by the laws of the State of Alabama, United States, without regard to its conflict of law provisions.

If you have any questions about these Terms, please contact the developer via the app store or support channel where the app was downloaded.
''',

    HelpKeys.privacyPolicy: '''
Privacy Policy

Effective Date: June 15, 2025

This Privacy Policy describes how FAI Assistant ("we", "our", or "the app") handles your information when you use the mobile application.

1. Data We Collect:
FAI Assistant collects only your name, and email for registration purposes. The app may also store certain data locally on your device to support its functionality, such as:

- Your acceptance of terms and policies
- Field preferences or app settings
- Subscription status or trial start date

2. Payment and Subscription:
If you choose to subscribe, we may store the payment status and expiration date locally to track your access to premium features. All billing is handled securely through the app store's payment system (e.g., Google Play or Apple App Store). We do not see or store your credit card information.

3. No Ads, No Third Parties:
FAI Assistant does not show ads, and we do not share your data with third-party companies, analytics providers, advertisers, or partners.

4. Offline-First Design:
The app works primarily offline but does contain 'Ask AI' functionality. Information stays on your device unless you explicitly export or share it.

5. Data Security:
We take reasonable precautions to protect the information stored locally on your device. However, no storage method is 100% secure.

6. Children's Privacy:
FAI Assistant is intended for professional and educational use by adults. It is not designed for children under 13, and we do not knowingly collect data from children.

7. Your Consent:
By using this app, you consent to this Privacy Policy. If you do not agree, please discontinue use of the app.

8. Changes to This Policy:
We may update this policy periodically. We encourage you to review it from time to time.

If you have questions or concerns about this Privacy Policy, contact us through the app store support channel where the app was downloaded.
''',

  };
}

/// A widget to display help text with auto-linked URLs.
class HelpTextScreen extends StatelessWidget {
  final String helpKey;
  final String? title;

  const HelpTextScreen({super.key, required this.helpKey, this.title});

  @override
  Widget build(BuildContext context) {
    final text = HelpText.texts[helpKey] ?? "Help text not found.";
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Help"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Linkify(
          onOpen: (link) async {
            final uri = Uri.parse(link.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          text: text,
          style: const TextStyle(fontSize: 16),
          linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}

// === OFFICIAL AS9102 FIELD TEXT MAP (actual spec text for each Form/Field) ===

const Map<String, String> as9102OfficialFieldText = {
  'Form1_Field1': 'Official AS9102 text for Form 1 Field 1 goes here.',
  'Form1_Field2': 'Official AS9102 text for Form 1 Field 2 goes here.',
  'Form1_Field3': 'Official AS9102 text for Form 1 Field 3 goes here.',
  'Form1_Field4': 'Official AS9102 text for Form 1 Field 4 goes here.',
  'Form1_Field5': 'Official AS9102 text for Form 1 Field 5 goes here.',
  'Form1_Field6': 'Official AS9102 text for Form 1 Field 6 goes here.',
  'Form1_Field7': 'Official AS9102 text for Form 1 Field 7 goes here.',
  'Form1_Field8': 'Official AS9102 text for Form 1 Field 8 goes here.',
  'Form1_Field9': 'Official AS9102 text for Form 1 Field 9 goes here.',
  'Form1_Field10': 'Official AS9102 text for Form 1 Field 10 goes here.',
  'Form1_Field11': 'Official AS9102 text for Form 1 Field 11 goes here.',
  'Form1_Field12': 'Official AS9102 text for Form 1 Field 12 goes here.',
  'Form1_Field13': 'Official AS9102 text for Form 1 Field 13 goes here.',
  'Form1_Field14': 'Official AS9102 text for Form 1 Field 14 goes here.',
  'Form1_Field15': 'Official AS9102 text for Form 1 Field 15 goes here.',
  'Form1_Field16': 'Official AS9102 text for Form 1 Field 16 goes here.',
  'Form1_Field17': 'Official AS9102 text for Form 1 Field 17 goes here.',
  'Form1_Field18': 'Official AS9102 text for Form 1 Field 18 goes here.',
  'Form1_Field19': 'Official AS9102 text for Form 1 Field 19 goes here.',
  'Form1_Field20': 'Official AS9102 text for Form 1 Field 20 goes here.',
  'Form1_Field21': 'Official AS9102 text for Form 1 Field 21 goes here.',
  'Form1_Field22': 'Official AS9102 text for Form 1 Field 22 goes here.',
  'Form1_Field23': 'Official AS9102 text for Form 1 Field 23 goes here.',
  'Form1_Field24': 'Official AS9102 text for Form 1 Field 24 goes here.',
  'Form1_Field25': 'Official AS9102 text for Form 1 Field 25 goes here.',
  'Form1_Field26': 'Official AS9102 text for Form 1 Field 26 goes here.',
// Form 2 Fields
  'Form2_Field1': 'Official AS9102 text for Form 2 Field 1 goes here.',
  'Form2_Field2': 'Official AS9102 text for Form 2 Field 2 goes here.',
  'Form2_Field3': 'Official AS9102 text for Form 2 Field 3 goes here.',
  'Form2_Field4': 'Official AS9102 text for Form 2 Field 4 goes here.',
  'Form2_Field5': 'Official AS9102 text for Form 2 Field 5 goes here.',
  'Form2_Field6': 'Official AS9102 text for Form 2 Field 6 goes here.',
  'Form2_Field7': 'Official AS9102 text for Form 2 Field 7 goes here.',
  'Form2_Field8': 'Official AS9102 text for Form 2 Field 8 goes here.',
  'Form2_Field9': 'Official AS9102 text for Form 2 Field 9 goes here.',
  'Form2_Field10': 'Official AS9102 text for Form 2 Field 10 goes here.',
  'Form2_Field11': 'Official AS9102 text for Form 2 Field 11 goes here.',
  'Form2_Field12': 'Official AS9102 text for Form 2 Field 12 goes here.',
  'Form2_Field13': 'Official AS9102 text for Form 2 Field 13 goes here.',
// Form 3 Fields
  'Form3_Field1': 'Official AS9102 text for Form 3 Field 1 goes here.',
  'Form3_Field2': 'Official AS9102 text for Form 3 Field 2 goes here.',
  'Form3_Field3': 'Official AS9102 text for Form 3 Field 3 goes here.',
  'Form3_Field4': 'Official AS9102 text for Form 3 Field 4 goes here.',
  'Form3_Field5': 'Official AS9102 text for Form 3 Field 5 goes here.',
  'Form3_Field6': 'Official AS9102 text for Form 3 Field 6 goes here.',
  'Form3_Field7': 'Official AS9102 text for Form 3 Field 7 goes here.',
  'Form3_Field8': 'Official AS9102 text for Form 3 Field 8 goes here.',
  'Form3_Field9': 'Official AS9102 text for Form 3 Field 9 goes here.',
  'Form3_Field10': 'Official AS9102 text for Form 3 Field 10 goes here.',
  'Form3_Field11': 'Official AS9102 text for Form 3 Field 11 goes here.',
  'Form3_Field12': 'Official AS9102 text for Form 3 Field 12 goes here.',
};