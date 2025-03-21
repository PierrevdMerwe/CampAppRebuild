// lib/src/shared/widgets/account_switch_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/login.dart';

class AccountSwitchCard extends StatefulWidget {
  final String targetAccountType;
  final String accountIdentifier;
  final String currentUid; // Add this to pass the current UID

  const AccountSwitchCard({
    Key? key,
    required this.targetAccountType,
    required this.accountIdentifier,
    required this.currentUid,
  }) : super(key: key);

  @override
  State<AccountSwitchCard> createState() => _AccountSwitchCardState();
}


class _AccountSwitchCardState extends State<AccountSwitchCard> {
  String targetEmail = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getTargetEmail();
  }

  Future<void> _getTargetEmail() async {
    try {
      String linkedUid = '';
      // Get the linked account UID
      if (widget.targetAccountType == "owner") {
        // Get linked owner UID for a camper
        final userDoc = await _firestore
            .collection('users')
            .where('firebase_uid', isEqualTo: widget.currentUid)
            .get();

        if (userDoc.docs.isNotEmpty) {
          linkedUid = userDoc.docs.first.data()['site_owner_uid'] ?? '';
        }
      } else {
        // Get linked camper UID for an owner
        final ownerDoc = await _firestore
            .collection('site_owners')
            .where('firebase_uid', isEqualTo: widget.currentUid)
            .get();

        if (ownerDoc.docs.isNotEmpty) {
          linkedUid = ownerDoc.docs.first.data()['camper_uid'] ?? '';
        }
      }

      // Get the email from the linked account
      if (linkedUid.isNotEmpty) {
        final collection = widget.targetAccountType == "owner" ? 'site_owners' : 'users';
        final doc = await _firestore
            .collection(collection)
            .where('firebase_uid', isEqualTo: linkedUid)
            .get();

        if (doc.docs.isNotEmpty) {
          setState(() {
            targetEmail = doc.docs.first.data()['email'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error getting target email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSwitchingToOwner = widget.targetAccountType == "owner";

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xff2e6f40).withValues(alpha: 0.1),
      child: InkWell(
        // In the AccountSwitchCard, modify the onTap method:
        onTap: () async {
          // Sign out before navigating to the login screen
          await FirebaseAuth.instance.signOut();

          // Also clear local user data
          await Provider.of<UserProvider>(context, listen: false).clearUserData();

          if (context.mounted) {
            // Navigate to login screen with pre-filled email
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  prefilledEmail: targetEmail.isNotEmpty ? targetEmail : '',
                  userType: isSwitchingToOwner ? 'Campsite Owner' : 'Camper',
                ),
              ),
                  (Route<dynamic> route) => false,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xff2e6f40).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSwitchingToOwner ? Icons.business : Icons.person,
                  color: const Color(0xff2e6f40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSwitchingToOwner
                          ? 'Switch to site owner'
                          : 'Switch to camper',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.accountIdentifier,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xff2e6f40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}