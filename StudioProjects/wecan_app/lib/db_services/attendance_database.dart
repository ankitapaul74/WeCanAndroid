import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new volunteer with assigned attendance days
  Future<void> addVolunteer(String name, int requiredDays) async {
    try {
      await _firestore.collection('volunteer_attendance').add({
        'name': name,
        'required_days': requiredDays, // Total days they need to attend
        'attended_days': 0, // Initially zero
      });
    } catch (e) {
      print("Error adding volunteer: $e");
    }
  }

  // Fetch all volunteers
  Stream<QuerySnapshot> getVolunteers() {
    return _firestore.collection('volunteer_attendance').snapshots();
  }

  // Increment attendance count
  Future<void> incrementAttendance(String docId, int currentDays) async {
    try {
      await _firestore.collection('volunteer_attendance').doc(docId).update({
        'attended_days': currentDays + 1,
      });
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }
}
