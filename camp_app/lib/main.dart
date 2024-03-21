import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart';
import 'theme_model.dart';

Future<void> resetFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstLaunch', true);
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await resetFirstLaunch();  // Reset the isFirstLaunch flag
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
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
        primaryColor: const Color(0xfff51957),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xfff51957),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xfff51957),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xfff51957)),
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
              return const LandingPage();
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

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Hello'),
            ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                // Set the 'isFirstLaunch' flag to true when the user signs out
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isFirstLaunch', true);
              },
            ),
          ],
        ),
      ),
    );
  }
}