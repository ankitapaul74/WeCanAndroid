import 'dart:io';
import 'dart:convert';
import 'package:WeCan/our_leaders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderFormScreen extends StatefulWidget {
  final String? leaderId;
  final Map<String, dynamic>? leaderData;

  LeaderFormScreen({this.leaderId, this.leaderData});

  @override
  _LeaderFormScreenState createState() => _LeaderFormScreenState();
}

class _LeaderFormScreenState extends State<LeaderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  final CollectionReference leadersCollection =
  FirebaseFirestore.instance.collection('leaders');

  @override
  void initState() {
    super.initState();
    if (widget.leaderData != null) {
      _nameController.text = widget.leaderData!['name'] ?? '';
      _positionController.text = widget.leaderData!['position'] ?? '';
      _yearController.text = widget.leaderData!['year'] ?? '';
      _emailController.text = widget.leaderData!['email'] ?? '';
      _linkedinController.text = widget.leaderData!['linkedin'] ?? '';
      _imageUrl = widget.leaderData!['image_url'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    final url = "https://api.cloudinary.com/v1_1/dtnbn7tgs/image/upload";
    final request = http.MultipartRequest("POST", Uri.parse(url));

    request.fields['upload_preset'] = "our_leaders";
    request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (response.statusCode == 200) {
      setState(() {
        _imageUrl = jsonResponse['secure_url'];
      });
    } else {
      print("Error uploading image: $responseData");
    }

    setState(() => _isUploading = false);
  }

  Future<void> _saveLeader() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage != null) await _uploadImage();

    final leaderData = {
      "name": _nameController.text.trim(),
      "position": _positionController.text.trim(),
      "year": _yearController.text.trim(),
      "email": _emailController.text.trim(),
      "linkedin": _linkedinController.text.trim(),
      "image_url": _imageUrl ?? "",
    };

    if (widget.leaderId == null) {
      await leadersCollection.add(leaderData);
    } else {
      await leadersCollection.doc(widget.leaderId).update(leaderData);
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OurLeadersScreen(),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.leaderId == null ? "Add Leader" : "Edit Leader",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),
        ),
        backgroundColor: Colors.teal,
        actions: widget.leaderId != null
            ? [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete Leader"),
                  content: Text(
                      "Are you sure you want to delete this leader?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        leadersCollection.doc(widget.leaderId).delete();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : null),
                    child: _selectedImage == null && _imageUrl == null
                        ? Icon(Icons.camera_alt, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                buildTextField("Name", _nameController),
                buildTextField("Position", _positionController),
                buildTextField("Year", _yearController, TextInputType.number),
                buildTextField("Email", _emailController, TextInputType.emailAddress),
                buildTextField("LinkedIn Profile", _linkedinController),
                SizedBox(height: 20),
                _isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveLeader,
                  child: Text(
                    widget.leaderId == null ? "Add Leader" : "Update Leader",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}