import 'package:cloud_firestore/cloud_firestore.dart';

class Note{
  final String id;
  final String? title;
  final String? content;
  final DateTime dateCreated;
  final String studentId;
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.studentId,
  });
  factory Note.fromMap(Map<String,dynamic> map){
    return Note(
      id:map['id']??'',
      title:map['title'],
      content:map['content'],
      dateCreated: (map['dateCreated'] as Timestamp).toDate(),
      studentId: map['studentId']??'',
    );
  }
  Map<String,dynamic> toMap(){
    return{
      'id':id,
      'title':title,
      'content':content,
      'dateCreated':Timestamp.fromDate(dateCreated),
      'studentId':studentId,
    };
  }
}