// lib/src/profile/screens/profile_screen.dart
import 'package:camp_app/src/profile/screens/personal_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  await userProvider.clearUserData();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SocialFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}