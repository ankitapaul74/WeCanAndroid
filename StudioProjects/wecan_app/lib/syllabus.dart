import 'package:WeCan/student.dart';
import 'package:WeCan/subject.dart';
import 'package:WeCan/syllabusmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'db_services/database_syll.dart';
import 'homescreen.dart';

import 'images2.dart';


class Syllabus extends StatefulWidget {
  @override
  _SyllabusState createState() => _SyllabusState();
}

class _SyllabusState extends State<Syllabus> {
  final TextEditingController _classController = TextEditingController();
  final DatabaseSyll _databaseSyll = DatabaseSyll();
  User? _currentUser;
  int _currentIndex = 1;

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

  Future<void> _addClass() async {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Class',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.yellow.shade800,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: 'Enter Class Name',
                labelStyle: TextStyle(color: Colors.yellow.shade800),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow.shade900, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                elevation: 6,
              ),
              onPressed: () async {
                final classname = _classController.text.trim();
                if (classname.isNotEmpty) {
                  try {
                    await _databaseSyll.addClass(classname);
                    _classController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Class added successfully!'),
                        backgroundColor: Colors.yellow.shade800,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding class: $e')),
                    );
                  }
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _deleteClass(String classId) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Class',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Colors.yellow.shade800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this class?',
            style: TextStyle(color: Colors.yellow.shade700),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.yellow.shade800),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _databaseSyll.deleteclass(classId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Class deleted successfully!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting class: $e')),
                  );
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }


  void _onTabTapped(int index) {
    if(index==_currentIndex) return;
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsPage()));
    } else if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryPage()));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow.shade800,
        title: Text(
          'Syllabus',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Class>>(
        stream: _databaseSyll.getClass(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No classes available',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }
          final names = snapshot.data!;
          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              final name = names[index];
              return Card(
                color: Colors.yellow.shade50,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.yellow.shade700,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text(
                    'Class: ${name.classname}',
                    style: GoogleFonts.laila(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubjectName(classId: name.id, className: name.classname),
                      ),
                    );
                  },
                  onLongPress:_currentUser!=null? () {
                    _deleteClass(name.id);
                  }:null,
                  trailing: Icon(Icons.chevron_right, color: Colors.yellow.shade800),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _currentUser!=null?FloatingActionButton(
        backgroundColor: Colors.yellow.shade700,
        onPressed: _addClass,
        child: Icon(Icons.add, color: Colors.white),
      ):null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_sharp, size: 30),
            label: 'Syllabus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_size_select_large),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Students',
          ),
        ],
        selectedItemColor: Colors.yellow.shade800,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}