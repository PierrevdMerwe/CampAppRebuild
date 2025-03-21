// lib/src/auth/services/account_linking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AccountLinkingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'AccountLinkingService');
  }

  Future<void> linkCamperToOwner(String camperUid, String ownerUid) async {
    try {
      _logDebug('🔄 Linking camper $camperUid to owner $ownerUid');

      // Update the site owner document
      final ownerDocs = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: ownerUid)
          .get();

      if (ownerDocs.docs.isEmpty) {
        throw 'Site owner not found';
      }

      await ownerDocs.docs.first.reference.update({
        'camper_uid': camperUid,
      });

      _logDebug('✅ Updated site owner document with camper link');

      // Update the camper document
      final camperDocs = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: camperUid)
          .get();

      if (camperDocs.docs.isEmpty) {
        throw 'Camper not found';
      }

      await camperDocs.docs.first.reference.update({
        'site_owner_uid': ownerUid,
      });

      _logDebug('✅ Updated camper document with owner link');
    } catch (e) {
      _logDebug('Failed to link accounts: $e', isError: true);
      throw 'Failed to link accounts: $e';
    }
  }

  Future<Map<String, dynamic>?> getLinkedOwnerAccount(String camperUid) async {
    try {
      _logDebug('🔍 Checking for linked owner account for camper: $camperUid');

      final camperDocs = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: camperUid)
          .get();

      if (camperDocs.docs.isEmpty) {
        return null;
      }

      final siteOwnerUid = camperDocs.docs.first.data()['site_owner_uid'];
      if (siteOwnerUid == null) {
        return null;
      }

      final ownerDocs = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: siteOwnerUid)
          .get();

      if (ownerDocs.docs.isEmpty) {
        return null;
      }

      return {
        'campsite_name': ownerDocs.docs.first.data()['campsite_name'],
        'firebase_uid': siteOwnerUid,
      };
    } catch (e) {
      _logDebug('Error checking linked owner account: $e', isError: true);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLinkedCamperAccount(String ownerUid) async {
    try {
      _logDebug('🔍 Checking for linked camper account for owner: $ownerUid');

      final ownerDocs = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: ownerUid)
          .get();

      if (ownerDocs.docs.isEmpty) {
        return null;
      }

      final camperUid = ownerDocs.docs.first.data()['camper_uid'];
      if (camperUid == null) {
        return null;
      }

      final camperDocs = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: camperUid)
          .get();

      if (camperDocs.docs.isEmpty) {
        return null;
      }

      return {
        'username': camperDocs.docs.first.data()['username'],
        'firebase_uid': camperUid,
      };
    } catch (e) {
      _logDebug('Error checking linked camper account: $e', isError: true);
      return null;
    }
  }
}