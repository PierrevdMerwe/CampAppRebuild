import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'user_service.dart';

class AppleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'AppleAuthService');
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      _logDebug('🍎 Starting Apple Sign In');

      // Get Apple credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuthCredential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        final isCamper = await _userService.isCamper(userCredential.user!.uid);

        if (!isCamper) {
          // Create new user profile if first time
          String? fullName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          if (fullName.isEmpty) fullName = 'Apple User';

          await _userService.createUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? 'noemail@apple.com',
            displayName: fullName,
            username: 'user${DateTime.now().millisecondsSinceEpoch}',
          );
          _logDebug('✅ Created new camper profile for Apple user');
        }
      }

      return userCredential;
    } catch (e) {
      _logDebug('Apple sign in error: $e', isError: true);
      throw 'Apple sign in failed';
    }
  }
}