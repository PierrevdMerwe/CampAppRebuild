import 'package:flutter/material.dart';

class MyAppColors {
  static const darkBlue = Color(0xFF1E1E2C);
  static const lightBlue = Color(0xFF2D2D44);
}

class MyAppThemes {
  static final lightTheme = ThemeData(
    primaryColor: MyAppColors.lightBlue,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primaryColor: MyAppColors.darkBlue,
    brightness: Brightness.dark,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dark Mode',
      theme: MyAppThemes.lightTheme,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: _themeMode, // Use _themeMode here
      home: MyHomePage(
        title: 'Flutter Dark Mode',
        key: UniqueKey(),
        toggleTheme: _toggleTheme, // Pass _toggleTheme to MyHomePage
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final void Function(ThemeMode) toggleTheme; // Add a callback here

  MyHomePage({
    required Key key,
    required this.title,
    required this.toggleTheme, // Add a parameter here
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Switch(
            value: isDarkMode,
            onChanged: (isOn) {
              widget.toggleTheme(
                isOn ? ThemeMode.dark : ThemeMode.light,
              ); // Use widget.toggleTheme here
            },
          ),
        ],
      ),
    );
  }
}


void main() {
  runApp(const MyApp());
}