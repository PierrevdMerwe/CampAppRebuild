// lib/src/auth/widgets/social_login_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: OutlinedButton.icon(
            onPressed: onGooglePressed,
            icon: Image.asset('images/google_logo.png', width: 24.0, height: 24.0),
            label: Text(
              'Continue with Google',
              style: GoogleFonts.montserrat(),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: OutlinedButton.icon(
            onPressed: onApplePressed,
            icon: Image.asset('images/apple.png', width: 40.0, height: 40.0),
            label: Text(
              'Continue with Apple',
              style: GoogleFonts.montserrat(),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}