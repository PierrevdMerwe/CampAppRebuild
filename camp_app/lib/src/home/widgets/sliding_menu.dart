// lib/src/home/widgets/sliding_menu.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/services/account_linking_service.dart';
import '../../core/services/profile_icon_service.dart';
import '../../settings/screens/contact_screen.dart';
import '../../shared/widgets/account_switch_card.dart';
import '../../auth/screens/account_linking_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';

class SlidingMenu extends StatelessWidget {
  final VoidCallback onClose;
  final AccountLinkingService _linkingService = AccountLinkingService();

  SlidingMenu({
    super.key,
    required this.onClose,
  });

  Widget _buildAccountSection(BuildContext context, String? camperUid) {
    // Temporarily hide the account linking section
    // Keep all the code intact for future use
    return const SizedBox.shrink();

    // Original implementation below kept for reference
    /*
  if (camperUid == null) return const SizedBox.shrink();

  return FutureBuilder<Map<String, dynamic>?>(
    future: _linkingService.getLinkedOwnerAccount(camperUid),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final linkedAccount = snapshot.data;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (linkedAccount != null) {
        // Show switch account card
        return AccountSwitchCard(
          targetAccountType: "owner",
          accountIdentifier: linkedAccount['campsite_name'] ?? 'Campsite',
          currentUid: userProvider.user?.uid ?? '',
        );
      }

      // Show link account button
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you also own a campsite\nand wish to list on the app?',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onClose(); // Close menu first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountLinkingScreen(
                        isLinkingToOwner: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2e6f40),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Link Owner Account',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  */
  }

  Future<void> _launchAboutWebsite(BuildContext context) async {
    final Uri url = Uri.parse('https://thecampp.com/about');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch website')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Consumer<UserProvider>(
              builder: (context, userProvider, _) => ProfileMenuHeader(
                onProfileTap: () {
                  onClose();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                onClose: onClose,
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items
            _MenuItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                onClose();
              },
            ),
            const SizedBox(height: 24),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'About Camp App',
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () {
                _launchAboutWebsite(context);
              },
            ),
            const SizedBox(height: 24),
            _MenuItem(
              icon: Icons.mail_outline,
              title: 'Contact Us',
              onTap: () {
                onClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactScreen()),
                );
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

            // Account Linking Section
            Consumer<UserProvider>(
              builder: (context, userProvider, _) =>
                  _buildAccountSection(context, userProvider.user?.uid),
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

class ProfileMenuHeader extends StatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onClose;

  const ProfileMenuHeader({
    Key? key,
    required this.onProfileTap,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ProfileMenuHeader> createState() => _ProfileMenuHeaderState();
}

class _ProfileMenuHeaderState extends State<ProfileMenuHeader> {
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
      print('Error loading profile icon in menu: $e');
      if (mounted) {
        setState(() {
          _isLoadingIcon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onProfileTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isLoadingIcon
                    ? const Color(0xff2e6f40)
                    : Color(int.parse(
                    "0x${_profileIconData?['background'] ?? 'FF2E6F40'}")),
                shape: BoxShape.circle,
              ),
              child: _isLoadingIcon
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : _profileIconData != null
                  ? Center(
                child: FaIcon(
                  _profileIconService.getIconData(
                    _profileIconData!['icon'],
                  ),
                  size: 20,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Text(
                    userProvider.user?.username != null
                        ? '@${userProvider.user?.username}'
                        : 'Hi Guest User',
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
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}