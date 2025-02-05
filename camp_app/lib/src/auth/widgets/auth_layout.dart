// lib/src/auth/widgets/auth_layout.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/constants/app_colors.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showBackButton;

  const AuthLayout({
    super.key,
    required this.title,
    required this.children,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}