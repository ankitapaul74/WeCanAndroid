import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class DatabaseService{
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> addStudent(String name,String studentClass)async {
    try{
      DocumentReference studentRef=await _firestore.collection('students').add({
        'name':name,
        'class':studentClass,
        'createdAt':FieldValue.serverTimestamp(),
      });
      await studentRef.collection('notes').add({
        'title':'Student Details',
        'content':'default',
        'isDefault':true,
        'timestamp':FieldValue.serverTimestamp(),
      });
    }catch(e){
      print('Error adding Student:$e');
    }
  }

  Stream<List<Student>> getStudents(){
    return _firestore.collection('students').snapshots().map((snapshot)
    =>snapshot.docs.map((doc)=>Student.fromDocument(doc)).toList());
  }

  Future<void> deleteStudent(String studentId) async{
    try{
      await _firestore.collection('students').doc(studentId).delete();
    } catch(e){
      print('Error deleting message $e');
    }
  }
}