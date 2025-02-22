import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth
import 'package:url_launcher/url_launcher_string.dart';
import 'leader_form.dart';

class LeaderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> leaderData;
  final String leaderId;

  LeaderDetailsScreen({required this.leaderData, required this.leaderId});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // ✅ Get the logged-in user

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          leaderData['name'] ?? "Leader Details",
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 3,
        iconTheme: IconThemeData(color: Colors.white),
        actions: user != null
            ? [ // ✅ Show options only if the user is logged in
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editLeader(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteLeader(context),
          ),
        ]
            : [], // ✅ Empty list if user is not logged in
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🚀 Profile Image
            Hero(
              tag: leaderData['image_url'] ?? '',
              child: CircleAvatar(
                radius: 75,
                backgroundColor: Colors.teal,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  backgroundImage: leaderData['image_url'] != null
                      ? NetworkImage(leaderData['image_url'])
                      : AssetImage("assets/default_avatar.png") as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildInfoCard(
              icon: Icons.person,
              text: leaderData['name'] ?? "Unknown",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              cardColor: Colors.purple[100]!,
              textColor: Colors.purple[900]!,
            ),
            SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.star,
              text: leaderData['position'] ?? "Volunteer",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              cardColor: Colors.orange[100]!,
              textColor: Colors.orange[900]!,
            ),
            SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.calendar_today,
              text: "Year: ${leaderData['year']}",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              cardColor: Colors.green[100]!,
              textColor: Colors.green[900]!,
            ),
            SizedBox(height: 10),
            if (leaderData['email'] != null)
              _buildClickableCard(
                context: context,
                icon: Icons.email,
                text: leaderData['email'],
                url: "mailto:${leaderData['email']}",
                cardColor: Colors.blue[100]!,
                textColor: Colors.blue[900]!,
              ),
            SizedBox(height: 10),
            if (leaderData['linkedin'] != null)
              _buildClickableCard(
                context: context,
                icon: Icons.link,
                text: "LinkedIn Profile",
                url: leaderData['linkedin'],
                cardColor: Colors.indigo[100]!,
                textColor: Colors.indigo[900]!,
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Reusable Info Card (Non-clickable)
  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: fontSize, fontWeight: fontWeight, color: textColor),
          ),
        ],
      ),
    );
  }

  /// Reusable Clickable Card for Email & LinkedIn
  Widget _buildClickableCard({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String url,
    required Color cardColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () async {
        final String encodedUrl = Uri.encodeFull(url);
        print("Opening URL: $encodedUrl"); // Debugging

        if (await canLaunchUrlString(encodedUrl)) {
          await launchUrlString(encodedUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open link: $url")),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            SizedBox(width: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: textColor, decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to edit a leader's details
  void _editLeader(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderFormScreen(leaderId: leaderId, leaderData: leaderData),
      ),
    );
  }

  /// Function to delete a leader from Firestore
  void _deleteLeader(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Leader"),
        content: Text("Are you sure you want to remove this leader?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('leaders').doc(leaderId).delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),

          ),
        ],

      ),
    );
  }
}

