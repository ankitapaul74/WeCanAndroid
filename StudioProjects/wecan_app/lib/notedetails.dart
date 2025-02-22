import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotedetailsPage extends StatefulWidget {
  final String title;
  final String content;
  final DocumentReference noteReference;

  const NotedetailsPage({
    Key? key,
    required this.title,
    required this.content,
    required this.noteReference,
  }) : super(key: key);

  @override
  State<NotedetailsPage> createState() => _NotedetailsPageState();
}

class _NotedetailsPageState extends State<NotedetailsPage> {
  late String title;
  late String content;
  late TextEditingController _contentController;

  bool isEditing = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    content = widget.content;
    _contentController = TextEditingController(text: content);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });
  }

  void toggleEditing() async {

    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _saveNote() async {
    setState(() {
      title = DateFormat('dd MMM, yyyy').format(DateTime.now());
      content = _contentController.text.trim();

      widget.noteReference.update({
        'title': title,
        'content': content,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson updated successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating Lesson: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });

      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? "Edit Note" : "Details",
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        elevation: 4,
        actions: [
          if (isLoggedIn&&!isEditing)
            IconButton(
              onPressed: toggleEditing,
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
        ],
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
                          title,
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.blue.shade300),
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
                              hintText: "Enter Content",
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
                onPressed: _saveNote,
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
