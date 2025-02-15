import 'package:camp_app/src/auth/providers/user_provider.dart';
import 'package:camp_app/src/auth/screens/welcome_screen.dart';
import 'package:camp_app/src/core/config/theme/theme_model.dart';
import 'package:camp_app/src/core/services/image_cache_service.dart';
import 'package:camp_app/src/home/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', false); // true = each launch is like first time, false = after setup process / not first time.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await resetFirstLaunch();

  final imageCacheService = ImageCacheService();
  await imageCacheService.clearExpiredCache();
  // Create a UserProvider instance to check current user
  final userProvider = UserProvider();
  userProvider.checkCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => userProvider),  // Use the instance we created
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    return isFirstLaunch;
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
      home: FutureBuilder<bool>(
        future: isFirstLaunch(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return const WelcomeScreen();
            } else {
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