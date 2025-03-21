// lib/src/auth/services/site_owner_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../core/services/profile_icon_service.dart';
import '../../utils/auth_utils.dart';

class SiteOwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'SiteOwnerService');
  }

  // Update the createSiteOwner method in site_owner_service.dart
  Future<void> createSiteOwner(
      String uid,
      String campsiteName,
      String email,
      String phone,
      {String? camperUid}
      ) async {
    try {
      _logDebug('📝 Creating new site owner in site_owners collection');

      // Format the campsite name for document ID
      final formattedName = AuthUtils.formatNameForFirestore(campsiteName);

      // Create profile icon service
      final profileIconService = ProfileIconService();
      final profileIcon = profileIconService.generateRandomProfileIcon();

      await _firestore.collection('site_owners').doc(formattedName).set({
        'firebase_uid': uid,
        'email': email,
        'phone': phone,
        'campsite_name': campsiteName,  // Original name with proper capitalization
        'verified': false,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'owned_sites': [],
        'profile': profileIcon,  // Add the profile icon
        if (camperUid != null) 'camper_uid': camperUid,
      });

      _logDebug('✅ Successfully created site owner profile');
    } catch (e) {
      _logDebug('Failed to create site owner profile: $e', isError: true);
      throw 'Failed to create site owner profile: ${e.toString()}';
    }
  }

  Future<bool> isSiteOwner(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      _logDebug('Failed to check if user is site owner: $e', isError: true);
      return false;
    }
  }

  Future<bool> isCampsiteNameUnique(String campsiteName) async {
    final formattedName = AuthUtils.formatNameForFirestore(campsiteName);
    final doc = await _firestore.collection('site_owners').doc(formattedName).get();
    return !doc.exists;
  }

  Future<Map<String, dynamic>?> getVerificationStatus(String uid) async {
    try {
      _logDebug('🔍 Checking verification status for site owner: $uid');

      // Query by firebase_uid field instead of document ID
      final querySnapshot = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _logDebug('❌ No site owner found with firebase_uid: $uid', isError: true);
        return null;
      }

      final doc = querySnapshot.docs.first;
      final status = {
        'verified': doc.data()['verified'] ?? false,
        'status': doc.data()['status'] ?? 'pending'
      };

      _logDebug('✅ Verification status retrieved: ${status['status']}');
      return status;
    } catch (e) {
      _logDebug('Failed to get verification status: $e', isError: true);
      return null;
    }
  }
}