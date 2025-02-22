import 'package:WeCan/syllabusdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addsyllabus.dart';

class SubjectName extends StatefulWidget {
  final String classId;
  final String className;

  const SubjectName({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  _SubjectNameState createState() => _SubjectNameState();
}

class _SubjectNameState extends State<SubjectName> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final CollectionReference classCollection =
  FirebaseFirestore.instance.collection('classSyllabus');
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }


  void _confirmDelete(DocumentReference subjectReference) {


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Syllabus'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await subjectReference.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syllabus deleted successfully!'),
                  backgroundColor: Colors.yellow,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Class ${widget.className}',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade800,
        elevation: 4,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search syllabus...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.yellow.shade400),
                  ),
                  filled: true,
                  fillColor: Colors.yellow.shade100,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: classCollection
                    .doc(widget.classId)
                    .collection('subjects')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No syllabus added yet.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                  final subjects = snapshot.data!.docs
                      .where((doc) => doc['title']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery))
                      .toList();

                  if (subjects.isEmpty) {
                    return Center(
                      child: Text(
                        'No results found for "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectDetails(
                                title: subject['title'],
                                content: subject['content'],
                                subjectReference: subject.reference,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.yellow.shade600, width: 2),
                          ),
                          elevation: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade700,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    subject['title'],
                                    style: GoogleFonts.kadwa(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Content Section
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    subject['content'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Delete Button
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 8, bottom: 8),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    onPressed: _currentUser!=null?() {
                                      _confirmDelete(subject.reference);
                                    }:null,
                                    icon: _currentUser!=null? Icon(
                                      Icons.delete_outline_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ):SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentUser!=null ?FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addsyllabus(classId: widget.classId),
            ),
          );
        },
        label: const Text(
          'Add Syllabus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.yellow.shade800,
      ):null,
    );
  }
}
