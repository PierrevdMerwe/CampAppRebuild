import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isDarkMode = false;
  bool isOtherFeature = false;
  bool isLocationPermission = false;
  bool isStoragePermission = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                        ),
                        value: isDarkMode,
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xfff51957),
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = value;
                          });
                        },
                        inactiveTrackColor: Colors.grey,
                        inactiveThumbColor: Colors.white,
                      ),
                      const SizedBox(height: 8.0), // Add spacing after each SwitchListTile
                      SwitchListTile(
                        title: Text(
                          'Some other feature Pierre forgot about',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 8.0), // Add spacing after each SwitchListTile
                      SwitchListTile(
                        title: Text(
                          'Location permission',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 8.0), // Add spacing after each SwitchListTile
                      SwitchListTile(
                        title: Text(
                          'Storage permission',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}