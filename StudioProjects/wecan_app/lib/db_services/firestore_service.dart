import 'package:cloud_firestore/cloud_firestore.dart';
import '../leader.dart';

class FirestoreService {
  final CollectionReference leadersCollection = FirebaseFirestore.instance.collection('leaders');

  Future<void> addLeader(Leader leader) async {
    await leadersCollection.add(leader.toMap());
  }

  Future<void> updateLeader(Leader leader) async {
    await leadersCollection.doc(leader.id).update(leader.toMap());
  }

  Future<void> deleteLeader(String id) async {
    await leadersCollection.doc(id).delete();
  }

  Stream<List<Leader>> getLeaders() {
    return leadersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Leader.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}
