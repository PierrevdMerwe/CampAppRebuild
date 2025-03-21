// lib/src/auth/screens/linking_success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login.dart';

class LinkingSuccessScreen extends StatelessWidget {
  final bool isLinkingToOwner;
  final String linkedAccountName; // campsite name or username
  final String email;

  const LinkingSuccessScreen({
    Key? key,
    required this.isLinkingToOwner,
    required this.linkedAccountName,
    required this.email,
  }) : super(key: key);

  void _launchSupport() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support.thecampp@gmail.com',
      query: 'subject=Account Linking Support',
    );
    launchUrl(emailLaunchUri);
  }

  List<String> get _ownerSteps => [
    'Your campsite owner account is pending verification',
    'You can switch accounts using the menu button',
    'You can also sign out and sign back in as a site owner',
    'Your account details will be reviewed within 24-48 hours',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLinkingToOwner) ...[
                  const Icon(
                    Icons.verified_user,
                    size: 64,
                    color: Color(0xff2e6f40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Created Successfully!',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Next Steps:',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    _ownerSteps.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xff2e6f40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _ownerSteps[index],
                              style: GoogleFonts.montserrat(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.link,
                    size: 64,
                    color: Color(0xff2e6f40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    linkedAccountName,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '↓',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    email,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'The accounts have now been linked',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2e6f40),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _launchSupport,
                  child: Text(
                    'Questions? Contact Support',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff2e6f40),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen and clear stack
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            prefilledEmail: email,
                            userType: isLinkingToOwner ? 'Campsite Owner' : 'Camper',
                          ),
                        ),
                            (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2e6f40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}