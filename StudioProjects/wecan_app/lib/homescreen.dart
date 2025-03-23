import 'dart:convert';
import 'package:WeCan/loginscreen.dart';
import 'package:WeCan/our_leaders.dart';
import 'package:WeCan/student.dart';
import 'package:WeCan/syllabus.dart';
import 'package:WeCan/volunteer_attendance.dart';
import 'package:WeCan/volunteers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carousel.dart';
import 'images2.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if(index==_currentIndex) return;
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsPage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Home',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: HomeScreenContent(),
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
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 6,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Laugh Live Learn Lead",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.image_outlined, color: Colors.green),
                    title: const Text(
                      'Add Images',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CarouselPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text(
                      'Attendance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  VolunteerAttendanceScreen()),
                      );
                    },
                  ),

                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final String today = [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday"
  ][DateTime.now().weekday % 7];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16.0),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('carouselImages').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No images available.'));
              }

              final docs = snapshot.data!.docs;
              final base64Images = docs.map((doc) => doc['image_data'] as String).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EnhancedCarousel(base64Images: base64Images),
              );
            },
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TodayCard(day: today),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: OurLeadersCard(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OurLeadersScreen()),
              );
            },),
          ),
        ],
      ),
    );
  }
}


class EnhancedCarousel extends StatefulWidget {
  final List<String> base64Images;
  EnhancedCarousel({required this.base64Images});

  @override
  _EnhancedCarouselState createState() => _EnhancedCarouselState();
}

class _EnhancedCarouselState extends State<EnhancedCarousel> {
  int _currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.base64Images.length,
          itemBuilder: (context, index, realIndex) {
            final imageBytes = base64Decode(widget.base64Images[index]);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),

              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),

            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() {
                _currentSlide = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.base64Images.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentSlide == index ? 12.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentSlide == index ? Colors.green : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class OurLeadersCard extends StatelessWidget {
  final VoidCallback onTap;

  const OurLeadersCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent.shade200, Colors.deepPurpleAccent.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Leaders",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Meet the passionate leaders of our club",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}


class TodayCard extends StatelessWidget {
  final String day;

  TodayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    if (day == "sunday") {
      return _buildHolidayCard(context, day.toUpperCase());
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('volunteers').doc(day).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(context, day.toUpperCase(), 'Loading...', [], null);
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildCard(context, day.toUpperCase(), "No Volunteers assigned", [], null);
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isHoliday = data['holiday'] ?? false;
        List<String> volunteers = List<String>.from(data['volunteers'] ?? []);
        DocumentReference? reference = snapshot.data!.reference;

        if (isHoliday) {
          return _buildHolidayCard(context, day.toUpperCase());
        }

        return _buildCard(
          context,
          day.toUpperCase(),
          volunteers.isEmpty ? "No volunteers assigned" : volunteers.join(', '),
          volunteers,
          reference,
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, List<String> volunteers, DocumentReference? reference) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VolunteerPage(),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Volunteer",
                          style: GoogleFonts.ibarraRealNova(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VolunteerPage()),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.beach_access, color: Colors.red.shade600, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Today is a holiday! 🎉\nNo volunteers are assigned today.",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
