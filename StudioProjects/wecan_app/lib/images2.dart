import 'package:WeCan/student.dart';
import 'package:WeCan/syllabus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'db_services/cloudinary_image_service.dart';
import 'homescreen.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _currentIndex = 2;
  bool isLoggedIn = false; // Initialize the login status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CloudinaryImageService>().fetchImages();
    });
    _checkLoginStatus();  // Check login status when the page loads
  }

  // Method to check login status
  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;  // Update the login status
    });
  }

  void _onTabTapped(int index) {
    if(index==_currentIndex) return;
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsPage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Syllabus()));
    } else if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
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
        title: Text(
          'Gallery',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (isLoggedIn)  // Show the button only if logged in
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                context.read<CloudinaryImageService>().uploadImage();
              },
            ),
        ],
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CloudinaryImageService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (service.imageUrls.isEmpty) {
            return Center(
              child: Text(
                'No images to display.',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: service.imageUrls.length,
            itemBuilder: (context, index) {
              final image = service.imageUrls[index];
              final imageUrl = image['image_url'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullImageView(image: image),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Material(
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
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
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}

class FullImageView extends StatelessWidget {
  final Map<String, dynamic> image;

  const FullImageView({required this.image});

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to log in to delete this image.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = image['image_url'];
    final String imageId = image['id'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          if (_isLoggedIn())  // Show the delete icon only if logged in
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Confirm Deletion',
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are you sure you want to delete this image? This action cannot be undone.',
                      style: GoogleFonts.lato(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm) {
                  await context.read<CloudinaryImageService>().deleteImage(imageId);
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}