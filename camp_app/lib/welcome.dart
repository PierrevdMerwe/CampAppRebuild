import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

void main() {
  runApp(const WelcomeScreen());
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String welcomeText = "";
  String descriptionText = "";
  bool isEllipsisAnimating = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _animateWelcomeText();
    });
  }

  void _animateWelcomeText() async {
    String text = "Welcome";
    for (int i = 0; i < text.length; i++) {
      setState(() {
        welcomeText = text.substring(0, i + 1);
      });
      await Future.delayed(
          const Duration(milliseconds: 250)); // Slower typing speed
    }
    _animateDescriptionText();
  }

  void _animateDescriptionText() async {
    String text = "The perfect camping getaway is at your fingertips...";
    for (int i = 0; i < text.length; i++) {
      setState(() {
        descriptionText = text.substring(0, i + 1);
      });
      await Future.delayed(
          const Duration(milliseconds: 100)); // Slower typing speed
    }
    _startEllipsisAnimation();
  }

  void _startEllipsisAnimation() async {
    setState(() {
      isEllipsisAnimating = true;
    });
    while (isEllipsisAnimating) {
      for (int i = 0; i < 3; i++) {
        setState(() {
          descriptionText =
              descriptionText.substring(0, descriptionText.length - 1);
        });
        await Future.delayed(
            const Duration(milliseconds: 250)); // Slower dot removal
      }
      for (int i = 0; i < 3; i++) {
        setState(() {
          descriptionText += ".";
        });
        await Future.delayed(
            const Duration(milliseconds: 250)); // Slower dot addition
      }
      await Future.delayed(const Duration(seconds: 1)); // Slower overall loop
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    setState(() {
      isEllipsisAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 100.0,
              ),
              SizedBox(
                height: 50.0,
                child: Text(
                  welcomeText,
                  style: GoogleFonts.montserrat(
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 80.0,
                child: Text(
                  descriptionText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                height: 400.0,
                width: 400.0,
                child: Image.asset('images/logo.jpg'),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 40.0,
                child: Builder(builder: (BuildContext context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff51957),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Sign me up!',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
