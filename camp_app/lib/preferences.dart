import 'package:camp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_model.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isOtherFeature = false;
  bool isLocationPermission = false;
  bool isStoragePermission = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SwitchListTile(
                              title: Text(
                                'Dark mode',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: themeModel.isDark
                                      ? Colors.white
                                      : Colors.black,
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
                            const SizedBox(height: 8.0),
                            // Add spacing after each SwitchListTile
                            SwitchListTile(
                              title: Text(
                                'Some other feature Pierre forgot about',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: themeModel.isDark
                                      ? Colors.white
                                      : Colors.black,
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
                            const SizedBox(height: 8.0),
                            // Add spacing after each SwitchListTile
                            SwitchListTile(
                              title: Text(
                                'Location permission',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: themeModel.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              value: isLocationPermission,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xfff51957),
                              onChanged: (value) {
                                setState(() {
                                  isLocationPermission = value;
                                });
                              },
                              inactiveTrackColor: Colors.grey,
                              inactiveThumbColor: Colors.white,
                            ),
                            const SizedBox(height: 8.0),
                            // Add spacing after each SwitchListTile
                            SwitchListTile(
                              title: Text(
                                'Storage permission',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: themeModel.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              value: isStoragePermission,
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xfff51957),
                              onChanged: (value) {
                                setState(() {
                                  isStoragePermission = value;
                                });
                              },
                              inactiveTrackColor: Colors.grey,
                              inactiveThumbColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24.0,
                    right: 36.0,
                    child: GestureDetector(
                      onTap: () {
                        if (isOtherFeature ||
                            isLocationPermission ||
                            isStoragePermission) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LandingPage()),
                          );
                        } else {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  'Are you sure you wish to skip your Preferences?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'No',
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LandingPage()),
                                      );
                                    },
                                    child: const Text(
                                      'Yes',
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
