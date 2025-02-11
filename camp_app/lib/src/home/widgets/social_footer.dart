// lib/src/home/widgets/social_footer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            _buildSocialIcon(Icons.tiktok, 'TikTok'),
            const SizedBox(width: 24),
            _buildSocialIcon(Icons.camera_alt, 'Instagram'),
            const SizedBox(width: 24),
            _buildSocialIcon(Icons.facebook, 'Facebook'),
            const SizedBox(width: 24),
            _buildSocialIcon(Icons.message, 'X'),
          ],
        ),
        const SizedBox(height: 30), // Bottom padding
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String platform) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: const Color(0xff2e6f40),
      ),
    );
  }
}