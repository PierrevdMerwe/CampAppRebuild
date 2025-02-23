// lib/src/campsite_owner/widgets/owner_sliding_menu.dart
import 'package:camp_app/src/campsite_owner/screens/owner_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../core/config/theme/theme_model.dart';
import '../../settings/screens/settings_screen.dart';

class OwnerSlidingMenu extends StatelessWidget {
  final VoidCallback onClose;

  const OwnerSlidingMenu({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                InkWell(
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OwnerProfileScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xff2e6f40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              return Text(
                                userProvider.user?.name ?? 'Site Owner', // Using name which contains campsite_name
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Menu Items
                _MenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    onClose();
                  },
                ),
                const SizedBox(height: 24),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'About Campp',
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    // TODO: Add website URL
                  },
                ),
                const SizedBox(height: 24),
                _MenuItem(
                  icon: Icons.mail_outline,
                  title: 'Contact',
                  onTap: () {
                    // TODO: Add contact handling
                  },
                ),
                const SizedBox(height: 24),
                _MenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const Spacer(),

                // Camper Account CTA
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Would you like to browse campsites\nand make bookings as a camper?',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Handle camper registration
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2e6f40),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Link here',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Version Info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Version 1.0.0',
                          style: GoogleFonts.montserrat(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff2e6f40).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'New version available!',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: const Color(0xff2e6f40),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff2e6f40), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}