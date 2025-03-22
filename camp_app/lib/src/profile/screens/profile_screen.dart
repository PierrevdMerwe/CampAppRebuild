// Complete updated version of profile_screen.dart

import 'package:camp_app/src/profile/screens/saved_campsites_screen.dart';
import 'package:camp_app/src/settings/screens/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login.dart';
import '../../home/widgets/social_footer.dart';
import '../../settings/screens/settings_screen.dart';
import '../../shared/screens/coming_soon_screen.dart';
import '../widgets/profile_menu_item.dart';
import 'personal_info_screen.dart';
import '../../core/services/profile_icon_service.dart';

// Profile Screen remains the same but uses the new ProfileHeader
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
                const ProfileHeader(), // Using our new stateful ProfileHeader
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
                      builder: (context) => const SavedCampsitesScreen(),
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
                      builder: (context) => const HelpSupportScreen(),
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

// New stateful ProfileHeader widget to handle loading the profile icon
class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ProfileIconService _profileIconService = ProfileIconService();
  Map<String, dynamic>? _profileIconData;
  bool _isLoadingIcon = true;

  @override
  void initState() {
    super.initState();
    _loadProfileIcon();
  }

  Future<void> _loadProfileIcon() async {
    setState(() {
      _isLoadingIcon = true;
    });

    try {
      final iconData = await _profileIconService.getUserProfileIcon();
      if (mounted) {
        setState(() {
          _profileIconData = iconData;
          _isLoadingIcon = false;
        });
      }
    } catch (e) {
      print('Error loading profile icon: $e');
      if (mounted) {
        setState(() {
          _isLoadingIcon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _isLoadingIcon
                ? const Color(0xff2e6f40)
                : Color(int.parse(
                "0x${_profileIconData?['background'] ?? 'FF2E6F40'}")),
            child: _isLoadingIcon
                ? const CircularProgressIndicator(color: Colors.white)
                : _profileIconData != null
                ? FaIcon(
              _profileIconService.getIconData(
                _profileIconData!['icon'],
              ),
              size: 40,
              color: Colors.white,
            )
                : const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.user;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.username ?? 'Guest User',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.userNumber != null)
                        Text(
                          ' ${user?.userNumber}',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'guest@example.com',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}