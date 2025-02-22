
import 'package:cloud_firestore/cloud_firestore.dart';
import '../syllabusmodel.dart';

class DatabaseSyll {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addClass(String classname) async {
    try {
      DocumentReference classnameRef = await _firestore.collection(
          'classSyllabus').add({
        'classname': classname,
        'CreatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding class:$e');
    }
  }

  Stream<List<Class>> getClass() {
    return _firestore.collection('classSyllabus').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Class.fromDocument(doc)).toList());
  }

  Future<void> deleteclass(String classId) async {
    try {
      await _firestore.collection('classSyllabus').doc(classId).delete();
    } catch (e) {
      print('Error deleting class:$e');
    }
  }
}