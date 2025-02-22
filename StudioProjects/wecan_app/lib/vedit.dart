import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VolunteerEditPage extends StatefulWidget {
  final String dayName;
  final List<String> volunteers;
  final DocumentReference dayReference;

  const VolunteerEditPage({
    Key? key,
    required this.dayName,
    required this.volunteers,
    required this.dayReference,
  }) : super(key: key);

  @override
  State<VolunteerEditPage> createState() => _VolunteerEditPageState();
}

class _VolunteerEditPageState extends State<VolunteerEditPage> {
  late List<String> volunteers;
  late List<TextEditingController> _volunteerControllers;
  bool isEditing = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    volunteers = List.from(widget.volunteers);
    _volunteerControllers = volunteers
        .map((volunteer) => TextEditingController(text: volunteer))
        .toList();

    // Get the current user
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    for (var controller in _volunteerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void toggleEditing() async {
    setState(() {
      if (isEditing) {
        volunteers = _volunteerControllers
            .map((controller) => controller.text.trim())
            .where((name) => name.isNotEmpty)
            .toList();

        widget.dayReference.update({
          'volunteers': volunteers,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Volunteers updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating volunteers: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      isEditing = !isEditing;
    });
  }

  void addVolunteerField() {
    setState(() {
      _volunteerControllers.add(TextEditingController());
    });
  }

  void removeVolunteerField(int index) {
    setState(() {
      _volunteerControllers[index].dispose();
      _volunteerControllers.removeAt(index);
      volunteers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? "Edit Volunteers" : "Volunteer Details",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.green.shade50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.green.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dayName,
                          style: GoogleFonts.saira(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(color: Colors.green.shade300),
                        SizedBox(height: 16),
                        Text(
                          "Volunteers for ${widget.dayName}",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _volunteerControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: isEditing
                                              ? Colors.grey.shade100
                                              : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 8,
                                              color: Colors.green.withOpacity(0.1),
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          controller: _volunteerControllers[index],
                                          enabled: isEditing,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                            hintText: "Enter volunteer name",
                                            hintStyle:
                                            TextStyle(color: Colors.grey.shade500),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isEditing)
                                      IconButton(
                                        icon: Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () => removeVolunteerField(index),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (isEditing && currentUser != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                onPressed: addVolunteerField,
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Add Volunteer",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (currentUser != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: toggleEditing,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: Text(
                                  isEditing ? "Save Changes" : "Edit",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
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
        ],
      ),
    );
  }
}
