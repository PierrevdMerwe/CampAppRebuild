// lib/src/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

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
      body: ListView(
        children: const [
          ProfileHeader(),
          SizedBox(height: 24),
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
          ),
          ProfileMenuItem(
            icon: Icons.history,
            title: 'Booking History',
          ),
          ProfileMenuItem(
            icon: Icons.favorite_border,
            title: 'Saved Campsites',
          ),
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
          ),
        ],
      ),
    );
  }
}