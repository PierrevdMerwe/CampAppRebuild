import 'package:camp_app/src/auth/providers/user_provider.dart';
import 'package:camp_app/src/auth/screens/welcome_screen.dart';
import 'package:camp_app/src/core/config/theme/theme_model.dart';
import 'package:camp_app/src/core/services/image_cache_service.dart';
import 'package:camp_app/src/home/screens/home_screen.dart';
import 'package:camp_app/src/campsite_owner/screens/owner_dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

Future<void> resetFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await resetFirstLaunch();

  final imageCacheService = ImageCacheService();
  await imageCacheService.clearExpiredCache();

  final userProvider = UserProvider();
  userProvider.checkCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _getStartupInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Get current Firebase user
    final currentUser = FirebaseAuth.instance.currentUser;
    bool isSiteOwner = false;

    if (currentUser != null) {
      developer.log('🔍 Checking user type for: ${currentUser.uid}', name: 'MainApp');

      // Check if user is a site owner
      try {
        final siteOwnerDoc = await FirebaseFirestore.instance
            .collection('site_owners')
            .where('firebase_uid', isEqualTo: currentUser.uid)
            .get();

        isSiteOwner = siteOwnerDoc.docs.isNotEmpty;
        developer.log('🏕️ Is site owner: $isSiteOwner', name: 'MainApp');
      } catch (e) {
        developer.log('❌ Error checking site owner status: $e', name: 'MainApp');
      }
    }

    return {
      'isFirstLaunch': isFirstLaunch,
      'isSiteOwner': isSiteOwner,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xff2e6f40),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xff2e6f40),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xff2e6f40),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff2e6f40)),
          ),
        ),
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: _getStartupInfo(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data?['isFirstLaunch'] == true) {
              developer.log('📱 Showing welcome screen (first launch)', name: 'MainApp');
              return const WelcomeScreen();
            } else if (snapshot.data?['isSiteOwner'] == true) {
              developer.log('🏕️ Routing to owner dashboard', name: 'MainApp');
              return const OwnerDashboardScreen();
            } else {
              developer.log('🏠 Routing to home screen', name: 'MainApp');
              return const HomeScreen();
            }
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}