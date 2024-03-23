import 'package:camp_app/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Controllers for Email and Pass
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Continue with Google
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Set a flag to indicate the user has just signed in
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('justSignedIn', true);

    return userCredential;
  }

  // Sign in with Email and Password
  Future<String?> signInWithEmail() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return 'Please enter both email and password.';
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /*
      firebase_auth/wrong-password
      firebase_auth/user-not-found

      Check issues met error codes, en check bug waar input fields clear op next.
      */

      return null; // return null if sign-in was successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(e);
        print(e.code);
        print(e.credential);
        print("User not found");
        return 'Please check your credentials again. If you are not a user, consider registering below.';
      }
    }

    return 'An unknown error occurred.';
  }

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('assets/sign.json'),
                    ),
                    const SizedBox(height: 40.0),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Discover your next ',
                            style: GoogleFonts.montserrat(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'adventure',
                            style: GoogleFonts.montserrat(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xfff51957),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 40.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          final String? errorMessage = await signInWithEmail();
                          if (errorMessage != null) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(errorMessage),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully logged in!'),
                              ),
                            );
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                const PreferencesScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff51957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Handle Google sign-in
                          final GoogleSignInAccount? googleUser =
                              await GoogleSignIn().signIn();
                          if (googleUser != null) {
                            final GoogleSignInAuthentication googleAuth =
                                await googleUser.authentication;
                            final OAuthCredential credential =
                                GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );
                            try {
                              final UserCredential userCredential =
                                  await _auth.signInWithCredential(credential);
                              // Check if sign-in was successful
                              if (userCredential.user != null) {
                                // Navigate to PreferencesScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PreferencesScreen()),
                                );
                              }
                            } on FirebaseAuthException {
                              // Handle error
                              //print(e.message);
                            }
                          }
                        },
                        icon: Image.asset('images/google_logo.png',
                            width: 24.0, height: 24.0),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Handle Apple sign-in
                        },
                        icon: Image.asset('images/apple.png',
                            width: 40.0, height: 40.0),
                        label: const Text('Continue with Apple'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0), // Add this line
                Column(
                  children: <Widget>[
                    const Divider(color: Colors.black),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Don\'t have an account? ',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
