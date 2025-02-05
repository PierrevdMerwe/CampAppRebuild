// lib/src/auth/widgets/social_login_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool visible;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16.0),
        Row(
          children: [
            const Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Or Sign in With',
                style: GoogleFonts.montserrat(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              onPressed: onGooglePressed,
              imagePath: 'images/google_logo.png',
              iconSize: 24,
            ),
            const SizedBox(width: 32.0),
            _buildSocialButton(
              onPressed: onApplePressed,
              imagePath: 'images/apple.png',
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String imagePath,
    required double iconSize,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50, // Fixed square size
        height: 50, // Fixed square size
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}