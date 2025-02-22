import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectDetails extends StatefulWidget {
  final String title;
  final String content;
  final DocumentReference subjectReference;

  const SubjectDetails({
    Key? key,
    required this.title,
    required this.content,
    required this.subjectReference,
  }) : super(key: key);

  @override
  State<SubjectDetails> createState() => _SubjectDetailsState();
}

class _SubjectDetailsState extends State<SubjectDetails> {
  late String title;
  late String content;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool isEditing = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    content = widget.content;
    _titleController = TextEditingController(text: title);
    _contentController = TextEditingController(text: content);

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void toggleEditing() async {
    setState(() {
      if (isEditing) {
        title = _titleController.text.trim();
        content = _contentController.text.trim();
        widget.subjectReference.update({
          'title': title,
          'content': content,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Syllabus updated successfully!'),
              backgroundColor: Colors.yellow.shade800,
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating syllabus: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          isEditing ? "Edit Syllabus" : "${widget.title} Syllabus",
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade800,
        elevation: 2,
        actions: [
          if (!isEditing && isLoggedIn)
            IconButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.yellow.shade50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.yellow.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            title,
                            style: GoogleFonts.kadwa(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.yellow.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.yellow.shade500),
                        const SizedBox(height: 16),
                        Expanded(
                          child: isEditing
                              ? TextField(
                            controller: _contentController,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Syllabus",
                            ),
                          )
                              : SingleChildScrollView(
                            child: Text(
                              content,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isEditing)
            Positioned(
              bottom: 28,
              right: 25,
              child: ElevatedButton(
                onPressed: toggleEditing,
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
