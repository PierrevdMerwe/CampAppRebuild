import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/config/theme/theme_model.dart';
import '../../home/widgets/social_footer.dart';
import '../screens/help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLocationPermission = false;
  bool isPhotosPermission = false;
  bool isNotificationsPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    if (mounted) {
      final locationStatus = await Permission.locationWhenInUse.status;
      final photosStatus = await Permission.photos.status;
      final notificationStatus = await Permission.notification.status;

      setState(() {
        isLocationPermission = locationStatus.isGranted;
        isPhotosPermission = photosStatus.isGranted;
        isNotificationsPermission = notificationStatus.isGranted;
      });
    }
  }

  Future<void> _handlePermission(Permission permission, String type) async {
    var status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (mounted) {
      setState(() {
        switch (type) {
          case 'location':
            isLocationPermission = status.isGranted;
            break;
          case 'photos':
            isPhotosPermission = status.isGranted;
            break;
          case 'notifications':
            isNotificationsPermission = status.isGranted;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final isDark = themeModel.isDark;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.montserrat(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection(
                      'Display',
                      [
                        ListTile(
                          title: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.moon,
                                  color: Color(0xff2e6f40), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Dark Mode',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff2e6f40)
                                      .withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Coming soon',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: const Color(0xff2e6f40),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Switch(
                            value: false,
                            onChanged: null,
                            // Disabled
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xff2e6f40),
                            inactiveTrackColor:
                                Colors.grey.withValues(alpha: .5),
                            inactiveThumbColor: Colors.white,
                          ),
                        ),
                      ],
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Permissions',
                      [
                        SwitchListTile(
                          title: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.locationDot,
                                  color: Color(0xff2e6f40), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Location permission',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          value: isLocationPermission,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xff2e6f40),
                          inactiveTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          onChanged: (value) async {
                            if (value) {
                              await _handlePermission(
                                  Permission.locationWhenInUse, 'location');
                            } else {
                              openAppSettings();
                            }
                          },
                        ),
                        SwitchListTile(
                          title: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.images,
                                  color: Color(0xff2e6f40), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Photo gallery permission',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          value: isPhotosPermission,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xff2e6f40),
                          inactiveTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          onChanged: (value) async {
                            if (value) {
                              await _handlePermission(
                                  Permission.photos, 'photos');
                            } else {
                              openAppSettings();
                            }
                          },
                        ),
                        SwitchListTile(
                          title: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.bell,
                                  color: Color(0xff2e6f40), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Notifications permission',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          value: isNotificationsPermission,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xff2e6f40),
                          inactiveTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          onChanged: (value) async {
                            if (value) {
                              await _handlePermission(
                                  Permission.notification, 'notifications');
                            } else {
                              openAppSettings();
                            }
                          },
                        ),
                      ],
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'App',
                      [
                        ListTile(
                          leading: const FaIcon(FontAwesomeIcons.code,
                              color: Color(0xff2e6f40), size: 20),
                          title: Text(
                            'Version',
                            style: GoogleFonts.montserrat(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          trailing: Text(
                            '1.0.0',
                            style: GoogleFonts.montserrat(color: Colors.grey),
                          ),
                        ),
                      ],
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff2e6f40),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.circleQuestion,
                          color: Color(0xff2e6f40), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Help & Support',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff2e6f40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SocialFooter(),
              const SizedBox(height: 24)
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children,
      {required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
