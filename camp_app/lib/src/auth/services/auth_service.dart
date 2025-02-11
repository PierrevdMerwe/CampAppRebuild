// lib/src/auth/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'apple_auth_service.dart';
import 'user_service.dart';
import 'site_owner_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  final SiteOwnerService _siteOwnerService = SiteOwnerService();
  final AppleAuthService _appleAuthService = AppleAuthService();

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'AuthService');
  }

  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required bool isCampOwner,
    String? username,
    String? displayName,
    String? phone,
    String? campsiteName,
  }) async {
    try {
      _logDebug('📝 Starting registration process for ${isCampOwner ? 'site owner' : 'camper'}');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _logDebug('🔑 Firebase Auth account created, setting up profile...');

        if (isCampOwner) {
          if (campsiteName == null || phone == null) {
            throw 'Campsite name and phone are required for site owners';
          }

          await _siteOwnerService.createSiteOwner(
            userCredential.user!.uid,
            campsiteName,
            email,
            phone,
          );

          _logDebug('✅ Site owner registered successfully');
        } else {
          if (username == null) {
            _logDebug('❌ Username is missing for camper registration');
            throw 'Username is required for campers';
          }

          _logDebug('👤 Creating camper profile...');
          await _userService.createUser(
            uid: userCredential.user!.uid,
            email: email,
            displayName: displayName ?? name,
            username: username,
          );

          _logDebug('✅ Camper registered successfully');
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      final errorMessage = _handleFirebaseAuthError(e);
      _logDebug('Registration error: ${e.code} - $errorMessage', isError: true);
      throw errorMessage;
    } catch (e) {
      _logDebug('Registration error: $e', isError: true);
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      _logDebug('🔑 Attempting sign in for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Check if user is a site owner
        final isSiteOwner = await _siteOwnerService.isSiteOwner(userCredential.user!.uid);
        if (isSiteOwner) {
          final verificationStatus = await _siteOwnerService.getVerificationStatus(userCredential.user!.uid);
          return {
            'user_credential': userCredential,
            'is_site_owner': true,
            'verification_status': verificationStatus
          };
        }

        // Check if user is a camper
        final isCamper = await _userService.isCamper(userCredential.user!.uid);
        if (isCamper) {
          return {
            'user_credential': userCredential,
            'is_site_owner': false,
            'verification_status': null
          };
        }

        throw 'User profile not found';
      }

      throw 'Sign in failed';
    } on FirebaseAuthException catch (e) {
      final errorMessage = _handleFirebaseAuthError(e);
      _logDebug('Sign in error: ${e.code} - $errorMessage', isError: true);
      throw errorMessage;
    }
  }

  // In auth_service.dart
  Future<Map<String, dynamic>> signInWithApple({required String userType}) async {
    if (userType == 'Campsite Owner') {
      throw 'Campsite owners must register with email and password';
    }

    try {
      final userCredential = await _appleAuthService.signInWithApple();

      if (userCredential?.user != null) {
        return {
          'user_credential': userCredential,
          'is_site_owner': false,
          'verification_status': null
        };
      }

      throw 'Apple sign in failed';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _logDebug('🔄 Initiating Google Sign In');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logDebug('❌ Google sign in aborted by user');
        throw 'Google sign in cancelled';
      }

      _logDebug('📱 Getting Google auth details');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in either collection
        final isSiteOwner = await _siteOwnerService.isSiteOwner(userCredential.user!.uid);
        final isCamper = await _userService.isCamper(userCredential.user!.uid);

        if (!isCamper && !isSiteOwner) {
          // Create new camper profile for Google sign-in
          await _userService.createUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: userCredential.user!.displayName ?? 'User',
            username: 'User${DateTime.now().millisecondsSinceEpoch}', // Generate temporary username
          );
          _logDebug('✅ Created new camper profile for Google user');
        }

        // Return appropriate response
        if (isSiteOwner) {
          final verificationStatus = await _siteOwnerService.getVerificationStatus(userCredential.user!.uid);
          return {
            'user_credential': userCredential,
            'is_site_owner': true,
            'verification_status': verificationStatus
          };
        }

        return {
          'user_credential': userCredential,
          'is_site_owner': false,
          'verification_status': null
        };
      }

      throw 'Google sign in failed';
    } catch (e) {
      _logDebug('Google sign in error: $e', isError: true);
      throw 'Google sign in failed';
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'An error occurred. Please try again';
    }
  }
}