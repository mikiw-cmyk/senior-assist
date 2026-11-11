import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'requests';

  // Submit a new assistance request
  Future<String?> submitRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String type,
    required String description,
    required String address,
  }) async {
    try {
      await _db.collection(_collection).add({
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'type': type,
        'description': description,
        'address': address,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'adminNote': null,
      });
      return null; // success
    } catch (e) {
      return 'Failed to submit request. Please try again.';
    }
  }

  // Get requests for a specific user (real-time)
  Stream<List<AssistanceRequest>> getUserRequests(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AssistanceRequest.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get ALL requests for admin (real-time)
  Stream<List<AssistanceRequest>> getAllRequests() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AssistanceRequest.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Admin: Update request status
  Future<String?> updateRequestStatus({
    required String requestId,
    required String status,
    String? adminNote,
  }) async {
    try {
      await _db.collection(_collection).doc(requestId).update({
        'status': status,
        'adminNote': adminNote,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // success
    } catch (e) {
      return 'Failed to update request.';
    }
  }
}
