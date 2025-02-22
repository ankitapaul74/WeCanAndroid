import 'package:cloud_firestore/cloud_firestore.dart';

class Class{
  final String id;
  final String classname;
  Class({required this.id,required this.classname});
  factory Class.fromDocument(DocumentSnapshot doc){
    final data=doc.data() as Map<String,dynamic>;
    return Class(
      id:doc.id,
      classname:doc['classname']??'',
    );
  }
}