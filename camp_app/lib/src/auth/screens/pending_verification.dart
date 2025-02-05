// lib/src/auth/screens/pending_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingVerificationScreen extends StatelessWidget {
  final String status;

  const PendingVerificationScreen({
    super.key,
    this.status = 'pending'
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status.toLowerCase() == 'rejected';

    // TODO: ADD: PLEASE ALLOW UP TO 1 WEEK FOR BEFORE APPLICATION COMMUNICATION
    //  CAN START AND ADD A VARIABLE TO TRACK TIME SPENT SO THAT THEY CAN FOLLOW
    //  UP IF TIME EXCEEDED

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRejected ? Icons.error_outline : Icons.hourglass_empty,
              size: 64,
              color: isRejected ? Colors.red : const Color(0xff2e6f40),
            ),
            const SizedBox(height: 24),
            Text(
              isRejected ? 'Verification Failed' : 'Verification Pending',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                isRejected
                    ? 'Your campsite owner account verification was unsuccessful. Please contact support for more information.'
                    : 'Your campsite owner account is pending verification. We\'ll notify you once your account has been approved.',
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