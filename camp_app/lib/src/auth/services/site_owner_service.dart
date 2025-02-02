import 'package:cloud_firestore/cloud_firestore.dart';

class SiteOwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createSiteOwner(String userId, String businessName, Map<String, dynamic> contactDetails) async {
    await _firestore.collection('site_owners').doc(userId).set({
      'verified': false,  // Initially set to false pending approval
      'businessName': businessName,
      'contactDetails': contactDetails,
      'ownedSites': [],  // Empty array initially
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // For approval workflow
    });
  }

  Future<bool> isSiteOwner(String userId) async {
    final doc = await _firestore.collection('site_owners').doc(userId).get();
    return doc.exists;
  }
}