import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> volunteerData;
  final String docId;

  const UpdateAttendanceScreen({Key? key, required this.volunteerData, required this.docId})
      : super(key: key);

  @override
  State<UpdateAttendanceScreen> createState() => _UpdateAttendanceScreenState();
}

class _UpdateAttendanceScreenState extends State<UpdateAttendanceScreen> {
  late int conducted;
  late int attended;

  @override
  void initState() {
    super.initState();
    conducted = (widget.volunteerData['Conducted'] ?? 0).toInt();
    attended = (widget.volunteerData['Attended'] ?? 0).toInt();
  }

  void markPresent() {
    setState(() {
      conducted += 1;
      attended += 1;
    });
  }

  void markAbsent() {
    setState(() {
      conducted += 1;
    });
  }

  void updateAttendance() {
    FirebaseFirestore.instance.collection('volunteersAttendance').doc(widget.docId).update({
      "Conducted": conducted,
      "Attended": attended,
      "lastUpdated": DateTime.now().toIso8601String(),
    }).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (conducted == 0) ? 0 : (attended / conducted) * 100;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Update Attendance",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _profileCard(widget.volunteerData['name'] ?? "Unknown", percentage),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _statCard("Conducted", conducted, Icons.event_note, Colors.indigo)),
                const SizedBox(width: 14),
                Expanded(child: _statCard("Attended", attended, Icons.check_circle, Colors.green)),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton("Present", Icons.thumb_up, Colors.green, markPresent),
                _actionButton("Absent", Icons.thumb_down, Colors.redAccent, markAbsent),
              ],
            ),
            const SizedBox(height: 32),
            _updateButton(),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(String name, double percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "Attendance: ${percentage.toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              Text(
                "$value",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
    );
  }

  Widget _updateButton() {
    return ElevatedButton(
      onPressed: updateAttendance,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
      ),
      child: Text(
        "Update Attendance",
        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}
