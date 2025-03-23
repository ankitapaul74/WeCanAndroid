import 'package:WeCan/update_attendance.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerAttendanceScreen extends StatelessWidget {
  final CollectionReference volunteers =
  FirebaseFirestore.instance.collection('volunteersAttendance');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Attendance",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: volunteers.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error loading data"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16),
            separatorBuilder: (context, index) => Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey.shade300,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              int conducted = (data['Conducted'] ?? 0).toInt();
              int attended = (data['Attended'] ?? 0).toInt();
              double percentage = conducted == 0 ? 0 : (attended / conducted) * 100;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateAttendanceScreen(
                          docId: doc.id, volunteerData: data),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(
                      context, doc.id, data['name'] ?? 'this volunteer');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPercentageCircle(percentage),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? "Unknown",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text("Attended: $attended | Conducted: $conducted",
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _smallAttendanceButton("P", Colors.green, () {
                            _markAttendance(doc.id, attended, conducted, true);
                          }),
                          SizedBox(width: 6),
                          _smallAttendanceButton("A", Colors.redAccent, () {
                            _markAttendance(doc.id, attended, conducted, false);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add, size: 28),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => _showAddVolunteerDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildPercentageCircle(double percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 58,
          width: 58,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 75
                  ? Colors.green
                  : (percentage >= 50 ? Colors.orange : Colors.redAccent),
            ),
          ),
        ),
        Text("${percentage.toStringAsFixed(0)}%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _smallAttendanceButton(String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _markAttendance(String docId, int attended, int conducted, bool isPresent) {
    FirebaseFirestore.instance.collection('volunteersAttendance').doc(docId).update({
      'Conducted': conducted + 1,
      'Attended': isPresent ? attended + 1 : attended,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  void _showAddVolunteerDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Add Volunteer", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
              child: Text("Add", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _addNewVolunteer(nameController.text.trim());
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewVolunteer(String name) {
    if (name.isEmpty) return;
    FirebaseFirestore.instance.collection('volunteersAttendance').add({
      "name": name,
      "Conducted": 0,
      "Attended": 0,
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Volunteer", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$name'? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('volunteersAttendance')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Volunteer deleted"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
