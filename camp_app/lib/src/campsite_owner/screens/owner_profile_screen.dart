// Complete updated version of owner_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login.dart';
import '../../settings/screens/settings_screen.dart';
import '../../shared/screens/coming_soon_screen.dart';
import '../../home/widgets/social_footer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../../core/services/profile_icon_service.dart';

import 'owner_personal_info_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  @override
  void initState() {
    super.initState();
    _debugUserData();
  }

  Future<void> _debugUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    developer.log('🔍 Current Firebase Auth User: ${currentUser?.uid}', name: 'OwnerProfileScreen');

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.user;
    developer.log('📊 UserProvider Data:', name: 'OwnerProfileScreen');
    developer.log('  - UID: ${userData?.uid}', name: 'OwnerProfileScreen');
    developer.log('  - Email: ${userData?.email}', name: 'OwnerProfileScreen');
    developer.log('  - Name: ${userData?.name}', name: 'OwnerProfileScreen');
    developer.log('  - Username: ${userData?.username}', name: 'OwnerProfileScreen');
    developer.log('  - User Type: ${userData?.userType}', name: 'OwnerProfileScreen');
  }

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
                const OwnerProfileHeader(), // Using our new stateful OwnerProfileHeader
                const SizedBox(height: 24),
                _buildMenuItem(
                  context,
                  Icons.person_outline,
                  'Personal Information',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OwnerPersonalInfoScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComingSoonScreen(
                        title: 'Help & Support',
                      ),
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

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: const Color(0xff2e6f40), size: 28),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// New stateful OwnerProfileHeader widget to handle loading the profile icon
class OwnerProfileHeader extends StatefulWidget {
  const OwnerProfileHeader({super.key});

  @override
  State<OwnerProfileHeader> createState() => _OwnerProfileHeaderState();
}

class _OwnerProfileHeaderState extends State<OwnerProfileHeader> {
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
                : const FaIcon(
              FontAwesomeIcons.tent,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.user;
              return Column(
                children: [
                  Text(
                    user?.name ?? 'Site Owner', // Using name which contains campsite_name
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'owner@example.com',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff2e6f40).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Campsite Owner',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xff2e6f40),
                        fontWeight: FontWeight.w500,
                      ),
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