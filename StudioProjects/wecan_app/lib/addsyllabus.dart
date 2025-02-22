import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addsyllabus extends StatefulWidget {
  final String classId;
  const Addsyllabus({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  State<Addsyllabus> createState() => _AddsyllabusState();
}

class _AddsyllabusState extends State<Addsyllabus> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final CollectionReference classCollection =
  FirebaseFirestore.instance.collection('classSyllabus');

  Future<void> _saveSyllabus() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        await classCollection.doc(widget.classId).collection('subjects').add({
          'title': title,
          'content': content,
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Syllabus added successfully'),
            backgroundColor: Colors.yellow.shade800,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding Syllabus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add Syllabus',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.yellow.shade800,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.yellow.shade50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 10,
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
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.kadwa(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.yellow.shade800,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.yellow.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter Subject name..',
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(color: Colors.yellow.shade500),
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
                              hintText: 'Enter syllabus...',
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
          Positioned(
            bottom: 28,
            right: 25,
            child: ElevatedButton(
              onPressed: _saveSyllabus,
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade800,
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
