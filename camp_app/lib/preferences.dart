import 'package:camp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_model.dart';
import 'package:permission_handler/permission_handler.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isOtherFeature = false;
  bool isLocationPermission = false;
  bool isStoragePermission = false;

  Future<void> completePreferences() async {
    // Unset the flag
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('justSignedIn', false);

    // Navigate to LandingPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
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
                      color: Color(0xfff51957),
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
          backgroundColor: themeModel.isDark ? Colors.black : Colors.white,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    'Preferences',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Lottie.asset('assets/gears.json', width: 70, height: 70),
                const SizedBox(height: 60,),
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Features', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xfff51957))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: const Divider(color: Colors.black),
                ),
                SwitchListTile(
                  title: Text(
                    'Dark mode',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  value: themeModel.isDark,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xfff51957),
                  onChanged: (value) {
                    setState(() {
                      themeModel.isDark = value;
                    });
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                SwitchListTile(
                  title: Text(
                    'Some other feature Pierre forgot about',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  value: isOtherFeature,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xfff51957),
                  onChanged: (value) {
                    setState(() {
                      isOtherFeature = value;
                    });
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                const SizedBox(height: 60,),
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Permissions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xfff51957))),
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
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  value: isLocationPermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xfff51957),
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status = await Permission.location.request();
                      setState(() {
                        isLocationPermission = status.isGranted;
                      });
                    } else {
                      setState(() {
                        isLocationPermission = false;
                      });
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
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  value: isStoragePermission,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xfff51957),
                  onChanged: (value) async {
                    if (value) {
                      PermissionStatus status = await Permission.storage.request();
                      setState(() {
                        isStoragePermission = status.isGranted;
                      });
                    } else {
                      setState(() {
                        isStoragePermission = false;
                      });
                    }
                  },
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                ),
                const SizedBox(height: 130.0), // Adjust as needed
                GestureDetector(
                  onTap: () {
                    if (themeModel.isDark ||
                        isOtherFeature ||
                        isLocationPermission ||
                        isStoragePermission) {
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
                                  TextSpan(text: 'We respect your decision to not allow us permission. Please note that this can be changed later on in '),
                                  TextSpan(text: 'Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' as this can make the app\'s experience better.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xfff51957),
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
                                    color: Color(0xfff51957),
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
                    themeModel.isDark ||
                        isOtherFeature ||
                        isLocationPermission ||
                        isStoragePermission
                        ? 'Continue'
                        : 'Skip',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xfff51957),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
