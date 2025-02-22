import 'package:cloud_firestore/cloud_firestore.dart';

class Student{
  final String id;
  final String name;
  final String studentClass;
  Student({required this.id,required this.name,required this.studentClass});
  factory Student.fromDocument(DocumentSnapshot doc){
    final data=doc.data() as Map<String,dynamic>;
    return Student(
      id:doc.id,
      name:doc['name']??'',
      studentClass: data['class']??'',
    );
  }
}