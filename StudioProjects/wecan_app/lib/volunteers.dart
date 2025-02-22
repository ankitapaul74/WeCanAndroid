import 'package:WeCan/vedit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class VolunteerPage extends StatefulWidget {
  @override
  _VolunteerPageState createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final List<String> days = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday"
  ];

  @override
  void initState() {
    super.initState();
    _initializeDaysInFirestore();
  }


  void _initializeDaysInFirestore() async {
    final CollectionReference volunteersCollection =
    FirebaseFirestore.instance.collection('volunteers');

    for (String day in days) {
      final DocumentSnapshot dayDoc = await volunteersCollection.doc(day).get();
      if (!dayDoc.exists) {
        await volunteersCollection.doc(day).set({
          "dayName": day[0].toUpperCase() + day.substring(1), // Capitalize day
          "volunteers": [], // Initially no volunteers
        });
        print("$day document created with default values.");
      }
    }
  }


  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Volunteers',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.volunteer_activism, color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) {
            return DayCard(
              day: days[index],
              onUpdate: refreshPage,
            );
          },
        ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final String day;
  final VoidCallback onUpdate;

  DayCard({required this.day, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('volunteers').doc(day).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            context: context,
            title: day.toUpperCase(),
            subtitle: "Loading...",
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildCard(
            context: context,
            title: day.toUpperCase(),
            subtitle: "No volunteers assigned",
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<String> volunteers = List<String>.from(data['volunteers'] ?? []);

        return _buildCard(
          context: context,
          title: day.toUpperCase(),
          subtitle: volunteers.isEmpty ? "No volunteers assigned" : volunteers.join(', '),
          onTap: () async {
            // Pass the volunteers data and reference to the next page for editing
            bool isUpdated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VolunteerEditPage(
                  dayName: data['dayName'] ?? day,
                  volunteers: volunteers,
                  dayReference: FirebaseFirestore.instance.collection('volunteers').doc(day),
                ),
              ),
            );

            if (isUpdated) {
              onUpdate();
            }
          },
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    void Function()? onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
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
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
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
