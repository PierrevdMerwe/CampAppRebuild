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
  bool isStoragePermission = false;

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
    // Check location permission
    var locationStatus = await Permission.location.status;
    // Check storage permission
    var storageStatus = await Permission.storage.status;

    setState(() {
      isLocationPermission = locationStatus.isGranted;
      isStoragePermission = storageStatus.isGranted;
    });
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
                  title: Text(
                    'Location permission',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  value: isLocationPermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xff2e6f40),
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status = await Permission.location.request();
                      setState(() {
                        isLocationPermission = status.isGranted;
                      });
                    } else {
                      // Open app settings if user wants to revoke permission
                      openAppSettings();
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                SwitchListTile(
                  title: Text(
                    'Storage permission',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  value: isStoragePermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xff2e6f40),
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status = await Permission.storage.request();
                      setState(() {
                        isStoragePermission = status.isGranted;
                      });
                    } else {
                      // Open app settings if user wants to revoke permission
                      openAppSettings();
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (isLocationPermission || isStoragePermission) {
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
                    isLocationPermission || isStoragePermission ? 'Continue' : 'Skip',
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
