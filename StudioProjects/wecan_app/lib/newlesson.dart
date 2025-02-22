import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Add extends StatefulWidget {
  final String studentId;

  const Add({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final TextEditingController _contentController = TextEditingController();
  final CollectionReference studentsCollection =
  FirebaseFirestore.instance.collection('students');

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });
  }

  Future<void> _saveLesson() async {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to add a lesson.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      try {
        final currentDate = DateFormat('dd MMM, yyyy').format(DateTime.now());
        final currentTimestamp = DateTime.now();

        await studentsCollection
            .doc(widget.studentId)
            .collection('notes')
            .add({
          'title': currentDate,
          'content': content,
          'timestamp': currentTimestamp,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesson added successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('dd MMM, yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add Lesson',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.blue.shade50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.blue.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDate,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(color: Colors.blue.shade300),
                        SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isLoggedIn
                                  ? 'Enter lesson content...'
                                  : 'Log in to add a lesson...',
                            ),
                            enabled: isLoggedIn,  // Disable the field if not logged in
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            right: 25,
            child: ElevatedButton(
              onPressed: isLoggedIn ? _saveLesson : null,  // Disable button if not logged in
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? Colors.blue : Colors.grey,  // Change button color if not logged in
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
