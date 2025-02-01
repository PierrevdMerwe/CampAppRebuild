import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _isPasswordLengthValid = false;
  bool _isPasswordUppercaseValid = false;
  bool _isPasswordLowercaseValid = false;
  bool _isPasswordNumberValid = false;
  bool _isPasswordSpecialCharValid = false;

  late final List<AnimationController> _controllers; // Define _controllers here

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      5,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 800)),
    );
  }

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

  // Register in with Email and Password
  Future<String?> registerWithEmail() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return 'Please enter both email and password.';
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Register successful
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email address. Please check and try again.';
        default:
          return 'Incorrect credentials have been entered, please try again. If you ARE registered please Login below.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet, int index) {
    // Update the controller's progress when the requirement's status changes
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (isMet) {
        _controllers[index].forward(); // Animate to the end
      } else {
        _controllers[index].reverse(); // Animate to the start
      }
    });

    return Row(
      children: <Widget>[
        Text(requirement),
        const Spacer(),
        SizedBox(
          width: 24,
          height: 24,
          child: Lottie.asset(
            'assets/register.json',
            controller: _controllers[index], // Use the controller
          ),
        ),
      ],
    );
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
                    color: Color(0xff2e6f40),
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
                              color: const Color(0xff2e6f40),
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
                      obscureText: _obscureText,
                      onChanged: (value) {
                        setState(() {
                          _isPasswordLengthValid = value.length >= 8;
                          _isPasswordUppercaseValid =
                              value.contains(RegExp(r'[A-Z]'));
                          _isPasswordLowercaseValid =
                              value.contains(RegExp(r'[a-z]'));
                          _isPasswordNumberValid =
                              value.contains(RegExp(r'[0-9]'));
                          _isPasswordSpecialCharValid =
                              value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: passwordController.text.isEmpty ? 0 : 120,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _buildPasswordRequirement(
                              'At least 8 characters',
                              _isPasswordLengthValid,
                              0,
                            ),
                            _buildPasswordRequirement(
                              'One uppercase',
                              _isPasswordUppercaseValid,
                              1,
                            ),
                            _buildPasswordRequirement(
                              'One lowercase',
                              _isPasswordLowercaseValid,
                              2,
                            ),
                            _buildPasswordRequirement(
                              'One number',
                              _isPasswordNumberValid,
                              3,
                            ),
                            _buildPasswordRequirement(
                              'One special character',
                              _isPasswordSpecialCharValid,
                              4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 40.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_isPasswordLengthValid &&
                              _isPasswordUppercaseValid &&
                              _isPasswordLowercaseValid &&
                              _isPasswordNumberValid &&
                              _isPasswordSpecialCharValid) {
                            final String? errorMessage =
                                await registerWithEmail();
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
                                  content: Text('Successfully registered!'),
                                ),
                              );
                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
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
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Your password must meet all the requirements.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2e6f40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Register',
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Successfully logged in!'),
                                  ),
                                );
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PreferencesScreen()),
                                );
                              }
                            } on FirebaseAuthException {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  content: const Text(
                                    'An unexpected error occurred. Please try again.',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Color(0xff2e6f40),
                                          fontFamily: 'Montserrat',
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
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
                          'Already have an account? ',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Login',
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
  @override
  void dispose() {
    // Dispose of the AnimationControllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
