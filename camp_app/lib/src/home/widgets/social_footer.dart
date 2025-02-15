import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialFooter extends StatelessWidget {
  const SocialFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.grey)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Follow us on',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(FontAwesomeIcons.facebookF, () {}),
            const SizedBox(width: 24),
            _buildSocialIcon(FontAwesomeIcons.xTwitter, () {}),
            const SizedBox(width: 24),
            _buildSocialIcon(FontAwesomeIcons.instagram, () {}),
            const SizedBox(width: 24),
            _buildSocialIcon(FontAwesomeIcons.tiktok, () {}),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50, // Fixed width
        height: 50, // Fixed height (same as width to ensure circle)
        decoration: BoxDecoration(
          color: const Color(0xff2e6f40).withValues(alpha: 0.1),
          shape: BoxShape.circle, // Use shape instead of borderRadius
        ),
        child: Center( // Center the icon
          child: FaIcon(
            icon,
            size: 20,
            color: const Color(0xff2e6f40),
          ),
        ),
      ),
    );
  }
}