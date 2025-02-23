
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Color(0xff2e6f40),
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Analytics features will be available soon',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}