import 'package:WeCan/syllabus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'db_services/database.dart';
import 'detailspage.dart';
import 'homescreen.dart';
import 'images2.dart';
import 'models.dart';

class StudentsPage extends StatefulWidget {
  @override
  _StudentsPageState createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  int _currentIndex = 3;
  bool isLoggedIn = false;
  String searchQuery = "";

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

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Syllabus()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryPage()));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  Future<void> _deleteStudent(String studentId) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Student'),
          content: Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _databaseService.deleteStudent(studentId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Student deleted successfully')),
                  );
                  Navigator.pop(context); // Close the dialog after deletion
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting student: $e')),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _addStudent() async {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
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
              'Add Student',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: 'Student Class',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                elevation: 4,
                shadowColor: Colors.blue.withOpacity(0.5),
              ),
              onPressed: () async {
                final name = _nameController.text.trim();
                final studentClass = _classController.text.trim();
                if (name.isNotEmpty && studentClass.isNotEmpty) {
                  try {
                    await _databaseService.addStudent(name, studentClass);
                    _nameController.clear();
                    _classController.clear();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding student: $e')),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Students',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search students by name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _databaseService.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No students added yet.',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                var students = snapshot.data!;
                students.sort((a, b) => a.studentClass.compareTo(b.studentClass));
                students = students
                    .where((student) => student.name.toLowerCase().contains(searchQuery))
                    .toList();
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      color: Colors.blue.shade50,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: AssetImage('assets/images/img.png'),
                        ),
                        title: Text(
                          student.name,
                          style: GoogleFonts.lato(color: Colors.blue, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Class: ${student.studentClass}',
                          style: TextStyle(fontSize: 17),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsPage(
                                studentId: student.id,
                                studentName: student.name,
                              ),
                            ),
                          );
                        },
                        onLongPress: isLoggedIn
                            ? () {
                          _deleteStudent(student.id);
                        }
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _addStudent,
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}
