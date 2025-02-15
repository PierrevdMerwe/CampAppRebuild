import 'package:camp_app/src/core/config/theme/theme_model.dart';
import 'package:camp_app/src/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

// In the _PreferencesScreenState class, remove the isOtherFeature variable
class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isLocationPermission = false;
  bool isPhotosPermission = false;
  bool isNotificationsPermission = false;

  @override
  void initState() {
    super.initState();
    // Check current permission status when screen loads
    _checkCurrentPermissions();
  }

  Future<void> completePreferences() async {
    // Unset the flag
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('justSignedIn', false);

    // Navigate to HomeScreen
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }
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

  Future<void> _handleLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (mounted) {
      setState(() {
        isLocationPermission = status.isGranted;
      });
    }
  }

  Future<void> _handlePhotosPermission() async {
    var status = await Permission.photos.status;

    if (status.isDenied) {
      status = await Permission.photos.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (mounted) {
      setState(() {
        isPhotosPermission = status.isGranted;
      });
    }
  }

  Future<void> _handleNotificationsPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (mounted) {
      setState(() {
        isNotificationsPermission = status.isGranted;
      });
    }
  }

  Widget _buildPermissionExplanation(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xff2e6f40)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, themeModel, child) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) => showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Please Complete Setup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: const Text(
                'Please complete the setup process first, any and all settings can be changed after initial setup.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      color: Color(0xff2e6f40),
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        child: Scaffold(
          backgroundColor: Colors.white, // Pure white background
          body: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    'Preferences',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Make Lottie animation bigger
                Lottie.asset('assets/gears.json', width: 150, height: 150),
                const SizedBox(height: 60),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Features',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2e6f40))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: const Divider(color: Colors.black),
                ),
                // Dark mode with coming soon
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Dark mode',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xff2e6f40).withOpacity(0.1),
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
                    onChanged: null, // Disabled
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xff2e6f40),
                    inactiveTrackColor: Colors.grey.withOpacity(0.5),
                    inactiveThumbColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Permissions',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2e6f40))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: const Divider(color: Colors.black),
                ),
                SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xff2e6f40)),
                      const SizedBox(width: 10),
                      Text(
                        'Location permission',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  value: isLocationPermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xff2e6f40),
                  onChanged: (value) async {
                    if (value) {
                      await _handleLocationPermission();
                    } else {
                      openAppSettings();
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.photo_library, color: Color(0xff2e6f40)),
                      const SizedBox(width: 10),
                      Text(
                        'Photo gallery permission',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  value: isPhotosPermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xff2e6f40),
                  onChanged: (value) async {
                    if (value) {
                      await _handlePhotosPermission();
                    } else {
                      openAppSettings();
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                SwitchListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.notifications, color: Color(0xff2e6f40)),
                      const SizedBox(width: 10),
                      Text(
                        'Notifications permission',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  value: isNotificationsPermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xff2e6f40),
                  onChanged: (value) async {
                    if (value) {
                      await _handleNotificationsPermission();
                    } else {
                      openAppSettings();
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Understanding App Permissions',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2e6f40),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildPermissionExplanation(
                                  Icons.location_on,
                                  'Location',
                                  'Enables discovery of nearby campsites and enhances your map navigation experience. This helps you easily find and navigate to your perfect camping destination.',
                                ),
                                const SizedBox(height: 15),
                                _buildPermissionExplanation(
                                  Icons.photo_library,
                                  'Photo Gallery',
                                  'Allows you to save memorable campsite photos and share them with friends and family. For campsite owners, this enables showcasing their facilities through high-quality images.',
                                ),
                                const SizedBox(height: 15),
                                _buildPermissionExplanation(
                                  Icons.notifications,
                                  'Notifications',
                                  'Keeps you informed about your booking status, upcoming stays, and exclusive offers from your favorite campsites. Stay connected with important updates about your outdoor adventures.',
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'I understand',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff2e6f40),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: Color(0xff2e6f40),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Why do we need these permissions?',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff2e6f40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (isLocationPermission || isPhotosPermission || isNotificationsPermission) {
                      completePreferences();
                    } else {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text(
                              'These permissions enhance your experience!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            content: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                      'We respect your decision to not allow us permission. Please note that this can be changed later on in '),
                                  TextSpan(
                                      text: 'Settings',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                      ' as this can make the app\'s experience better.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xff2e6f40),
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  completePreferences();
                                },
                                child: const Text(
                                  'Proceed',
                                  style: TextStyle(
                                    color: Color(0xff2e6f40),
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    isLocationPermission || isPhotosPermission || isNotificationsPermission ? 'Continue' : 'Skip',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2e6f40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}
