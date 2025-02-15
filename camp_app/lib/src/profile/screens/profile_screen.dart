// lib/src/profile/screens/profile_screen.dart
import 'package:camp_app/src/profile/screens/personal_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/widgets/social_footer.dart';
import '../../settings/screens/settings_screen.dart';
import '../../shared/screens/coming_soon_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

// lib/src/profile/screens/profile_screen.dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const ProfileHeader(),
                const SizedBox(height: 24),
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Booking History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(title: 'Booking History'),
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.favorite_border,
                  title: 'Saved Campsites',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(title: 'Saved Campsites'),
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(title: 'Help & Support'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SocialFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}