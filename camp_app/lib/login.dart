import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: 20.0),
                  Text(
                    'Discover your next adventure',
                    style: GoogleFonts.montserrat(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 40.0,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                PreferencesScreen(),
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
                            await _auth.signInWithCredential(credential);
                            // Display message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Signed in successfully')),
                            );
                          } on FirebaseAuthException catch (e) {
                            // Handle error
                            print(e.message);
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
                        onTap: () {},
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
    );
  }
}